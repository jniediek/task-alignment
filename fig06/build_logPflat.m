function logPflat = build_logPflat(Policy)
%BUILD_LOGPFLAT  Flatten the policy tensor into the Kx10201 log-policy matrix
%   used by FIT_BETA_MLE.
%
%   POLICY is the 200x101x101 tensor from policy.mat, with
%   POLICY(k, s+1, a) = pi_beta_k(action a | state s).
%
%   The 1e-10 floor mirrors beta_fitting.LOG_PROB_FLOOR and keeps
%   zero-probability actions (a > s) from producing -Inf.

LOG_PROB_FLOOR = 1e-10;
logPflat = log(max(reshape(Policy, size(Policy, 1), []), LOG_PROB_FLOOR));
end
