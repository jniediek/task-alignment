function [beta_hat, ll] = fit_beta_mle(state, action, betas, logPflat)
%FIT_BETA_MLE  Grid-search MLE of the task-alignment parameter beta.
%
%   [BETA_HAT, LL] = FIT_BETA_MLE(STATE, ACTION, BETAS, LOGPFLAT) returns the
%   beta in BETAS maximising the mean log-likelihood of the choice steps
%   (STATE, ACTION) under the softmax policy family, together with the full
%   log-likelihood curve LL (one entry per beta).
%
%   This is the MATLAB port of beta_fitting.fit_beta_mle / log_likelihood_curve
%   in the Python reference implementation, and reproduces it exactly.
%
%   Inputs
%     STATE, ACTION  Nx1 numeric. STATE is the interval size before the guess
%                    (1..100); ACTION is the 1-indexed rank of the guess within
%                    that interval (1..STATE). Pool as many steps as you like --
%                    the fit only sees the multiset of (state, action) pairs.
%     BETAS          Kx1 ascending beta grid, from policy.mat.
%     LOGPFLAT       Kx10201 flattened log-policy, built once by BUILD_LOGPFLAT.
%
%   Ties in the argmax resolve to the lowest beta, matching Python's
%   max(dict, key=...) which keeps the first (= lowest-beta) maximum.

n_states = 101;

% Column-major linear index into reshape(Policy, K, []): the flattened column
% for policy entry (state s, action a) is (a-1)*101 + (s+1). Getting this
% ordering wrong is the single easiest way to silently break the port.
lin = double(action(:) - 1) * n_states + double(state(:)) + 1;

% The likelihood depends only on how often each (state, action) cell occurs,
% so collapse the steps into counts and evaluate all betas in one product.
cnt = accumarray(lin, 1, [size(logPflat, 2) 1]);

ll = (logPflat * cnt) / sum(cnt);   % mean (not sum) log-likelihood, as in Python

[~, k] = max(ll);                  % max returns the first index on ties
beta_hat = betas(k);
end
