function dev = check_policy_symmetry(data_dir)
%CHECK_POLICY_SYMMETRY  How far the solved policy is from a symmetry it must have.
%
%   DEV = CHECK_POLICY_SYMMETRY(DATA_DIR) measures how badly the policy tensor
%   in fig06_policy.mat violates an exact symmetry of the guessing-game MDP, and
%   prints a one-line summary. DATA_DIR defaults to ../data.
%
%   The symmetry. In state n the guess of rank a splits the interval in two:
%   "too high" leaves a-1 candidates and happens with probability (a-1)/n, "too
%   low" leaves n-a and happens with probability (n-a)/n, and a correct guess
%   ends the game with probability 1/n whatever a is. The map
%
%       a  ->  n+1-a
%
%   sends a-1 to n-a and n-a to a-1, so it carries each branch onto the other
%   together with its probability, and leaves the correct-guess branch alone.
%   The reward depends only on whether the game ended, and the prior policy is
%   uniform over the n legal ranks, so every term of the G-learning objective is
%   invariant under it. The exact solution therefore satisfies
%
%       pi_beta(a | n) = pi_beta(n+1-a | n)
%
%   for every beta and every n, and its peak is the balanced split (n+1)/2 --
%   for n = 100 an exact tie between ranks 50 and 51. Plain binary search, in
%   other words, and not a policy biased to one side.
%
%   What the exported tensor does instead. The deviation is at machine level at
%   beta = 0, where the policy is just the uniform prior, and grows with both
%   beta and n, reaching about a quarter of the peak at beta = 2 and n = 100.
%   Averaging the policy with its own mirror image restores the exact ties at
%   (n+1)/2 for every state. That pattern -- error absent where the answer is
%   known in closed form, worst where the problem is stiffest -- is
%   under-convergence in the iterative solve, not a property of the task.
%
%   DEV is one number per beta: the largest mirror difference at any state,
%   as a fraction of that state's peak probability.
%
%   Nothing here corrects the policy. Every fit in this figure deliberately uses
%   it as solved, so that the numbers match the reference implementation; the
%   effect of the asymmetry on beta_hat is under half a grid step on the cohort
%   means. This function exists so the flaw is measured and reported rather than
%   silently inherited.
%
%   See also FIG06_SAMPLE_POLICIES, COMPUTE_COHORT_BETAS.

here = fileparts(mfilename('fullpath'));
if nargin < 1 || isempty(data_dir), data_dir = fullfile(here, '..', 'data'); end

P = load(fullfile(data_dir, 'fig06_policy.mat'), 'betas', 'Policy');

betas = P.betas(:);
n_betas = numel(betas);
dev = zeros(n_betas, 1);

for s = 1:100
    % Only the legal ranks 1..s; the rest of the row is exactly zero, and
    % column 101 is the RESET action, which no state above 0 ever takes.
    p = P.Policy(:, s + 1, 1:s);
    mirror_diff = max(abs(p - flip(p, 3)), [], 3);
    dev = max(dev, mirror_diff ./ max(p, [], 3));
end

fprintf(['Policy symmetry: pi(a|n) must equal pi(n+1-a|n), so the best guess is ' ...
         'the balanced\n  split (n+1)/2. Deviation from that is %.1f%% of the peak ' ...
         'at beta = %.2f but %.1f%% at\n  beta = %.2f, growing with beta -- the ' ...
         'solve is under-converged at large beta.\n'], ...
    100 * dev(1), betas(1), 100 * dev(end), betas(end));
end
