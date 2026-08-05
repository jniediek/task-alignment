function [fits, betas, logPflat] = fit_subject_betas(data_dir)
%FIT_SUBJECT_BETAS  Grid-search MLE of beta, one fit per subject.
%
%   [FITS, BETAS, LOGPFLAT] = FIT_SUBJECT_BETAS(DATA_DIR)
%
%   Fits one beta_hat to every subject, pooling all of that subject's choice
%   steps across all of their games. No subject is excluded and no game is
%   dropped: the cohort rules of COMPUTE_COHORT_BETAS, including its exclusion
%   of the six most active players, belong to that analysis alone and must not
%   leak in here.
%
%   Inputs
%     DATA_DIR  folder holding fig06_steps.mat and fig06_policy.mat.
%               Default: ../data, i.e. the repository's shared data folder.
%
%   Outputs
%     FITS      1xM struct array, one entry per subject, in the order the
%               subjects are stored in fig06_steps.mat, with fields
%                 subject_id  the numeric id
%                 subject     its 1-based index into subject_ids
%                 beta_hat    the fitted beta
%                 n_steps     number of choice steps the fit saw
%                 n_games     total completed games
%     BETAS     the beta grid, and
%     LOGPFLAT  the flattened log-policy, both returned so a caller that needs
%               per-subject log-likelihood curves can pass them straight back
%               into FIT_BETA_MLE instead of rebuilding LOGPFLAT per subject.
%               Building it is the only expensive step here.
%
%   The stored subject order is Python's lexicographic sort of the
%   user_<id>.pkl filenames, not a numeric sort. Callers that select a subject
%   by proximity to some target beta inherit that order as their tie-break, so
%   do not reorder FITS before selecting.
%
%   Reporting is left to the callers, so this stays usable from any figure.
%
%   See also FIT_BETA_MLE, BUILD_LOGPFLAT, COMPUTE_COHORT_BETAS.

here = fileparts(mfilename('fullpath'));
if nargin < 1 || isempty(data_dir), data_dir = fullfile(here, '..', 'data'); end

S = load(fullfile(data_dir, 'fig06_steps.mat'));
P = load(fullfile(data_dir, 'fig06_policy.mat'), 'betas', 'Policy');

betas    = P.betas(:);
logPflat = build_logPflat(P.Policy);

subject = double(S.subject(:));
state   = double(S.state(:));
action  = double(S.action(:));
n_games = double(S.n_games(:));

n_subjects = numel(S.subject_ids);

fits = struct('subject_id', cell(1, n_subjects), 'subject', [], ...
              'beta_hat', [], 'n_steps', [], 'n_games', []);

for i = 1:n_subjects
    sel = subject == i;

    fits(i).subject_id = S.subject_ids(i);
    fits(i).subject    = i;
    fits(i).beta_hat   = fit_beta_mle(state(sel), action(sel), betas, logPflat);
    fits(i).n_steps    = sum(sel);
    fits(i).n_games    = n_games(i);
end
end
