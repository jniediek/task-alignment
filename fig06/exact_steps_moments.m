function [mean_steps, sd_steps, E1, E2] = exact_steps_moments(Policy, start_state)
%EXACT_STEPS_MOMENTS  Exact mean and SD of guesses-per-game, per beta.
%
%   [MEAN_STEPS, SD_STEPS] = EXACT_STEPS_MOMENTS(POLICY) returns Kx1 vectors
%   with the exact expected number of guesses per game, and its per-game
%   standard deviation, under each of the K policies in POLICY, starting from
%   state 100.
%
%   [...] = EXACT_STEPS_MOMENTS(POLICY, START_STATE) starts elsewhere.
%
%   [MEAN_STEPS, SD_STEPS, E1, E2] = EXACT_STEPS_MOMENTS(...) also returns the
%   full Kx101 moment tables, E1(k, s+1) = E[T_s] and E2(k, s+1) = E[T_s^2]
%   under policy k, where T_s is the number of guesses needed to reach state 0
%   from state s.
%
%   POLICY is the 200x101x101 tensor from policy.mat, with
%   POLICY(k, s+1, a) = pi_beta_k(action a | state s). Note the s+1 row offset,
%   the same one documented in README.md -- state s lives in row s+1 because
%   state 0 occupies row 1.
%
%   This is the MATLAB port of exact_steps_moments / exact_mean_sd in
%   code/fig02_variant_exact_avg_steps.py.
%
%   WHY THIS IS A SINGLE FORWARD SWEEP AND NOT A LINEAR SOLVE
%   ---------------------------------------------------------
%   With state s = the number of still-possible values and action a = the
%   1-indexed rank of the guess inside that interval, the transition is
%
%       correct    w.p. 1/s        -> state 0
%       too high   w.p. (a-1)/s    -> state a-1
%       too low    w.p. (s-a)/s    -> state s-a
%
%   Every reachable successor is STRICTLY smaller than s: a-1 <= s-1 because
%   a <= s, and s-a <= s-1 because a >= 1. The state chain is therefore a DAG
%   ordered by s -- it can never revisit a state or move upward. First-step
%   analysis,
%
%       E[T_s] = 1 + sum_s' w_s(s') E[T_s'],      E[T_0] = 0,
%
%   with w_s the transition kernel with the action marginalised out, then needs
%   no matrix inverse and no iteration: sweeping s = 1, 2, ..., 100 upward, the
%   right-hand side only ever reads values that are already known. Squaring the
%   same one-step identity T_s = 1 + T_S' gives E[T_s^2] on the same sweep, and
%   hence the exact standard deviation.
%
%   The results are exact, not sampled: they are what
%   beta_fitting.simulate_policy_games estimates in the Python original, with
%   the Monte Carlo error removed.
%
%   See also BUILD_LOGPFLAT, FIG02_BETA_VS_AVG_STEPS.

if nargin < 2 || isempty(start_state), start_state = 100; end

K = size(Policy, 1);
n_states = size(Policy, 2);

E1 = zeros(K, n_states);
E2 = zeros(K, n_states);

for k = 1:K
    e1 = zeros(1, n_states);
    e2 = zeros(1, n_states);

    for s = 1:n_states - 1
        % Row s+1 holds state s. Renormalise over the s legal actions, as
        % beta_fitting.simulate_one_game does with cum_row / total.
        p = reshape(Policy(k, s + 1, 1:s), [s 1]);
        p = p / sum(p);
        a = (1:s)';

        % w(j) = P(next state = j-1 | state s), action marginalised out. Only
        % states 0..s-1 are reachable, so w has length s; state s' sits at
        % index s'+1.
        %
        % Within each branch the target indices are a permutation of 1..s with
        % no repeats, so plain indexed addition is correct here -- MATLAB does
        % NOT accumulate over duplicate subscripts, which is why the three
        % branches are written as three separate statements rather than one.
        w = zeros(s, 1);
        w(1)         = w(1)         + 1 / s;                % correct  -> 0
        w(a)         = w(a)         + p .* (a - 1) / s;     % too high -> a-1
        w(s - a + 1) = w(s - a + 1) + p .* (s - a) / s;     % too low  -> s-a

        m1 = w' * e1(1:s)';
        m2 = w' * e2(1:s)';
        e1(s + 1) = 1 + m1;                 % T_s   = 1 + T_S'
        e2(s + 1) = 1 + 2 * m1 + m2;        % T_s^2 = 1 + 2 T_S' + T_S'^2
    end

    E1(k, :) = e1;
    E2(k, :) = e2;
end

% Analytically known, policy-independent, and cheap: E[T_1] = 1 (one candidate
% left, one guess) and E[T_2] = 1.5 (with two candidates no policy can do
% better or worse than a coin flip). A transposed policy row or a wrong
% transition kernel breaks at least one of these. Same assertions as the
% Python side.
assert(all(E1(:, 2) == 1),   'E[T_1] must be exactly 1 for every beta');
assert(all(E1(:, 3) == 1.5), 'E[T_2] must be exactly 1.5 for every beta');

mean_steps = E1(:, start_state + 1);
sd_steps = sqrt(max(E2(:, start_state + 1) - mean_steps .^ 2, 0));
end
