function [cohorts, info] = compute_cohort_betas(data_dir, thresholds, n_excluded)
%COMPUTE_COHORT_BETAS  beta_hat per game number, within fixed subject cohorts.
%
%   [COHORTS, INFO] = COMPUTE_COHORT_BETAS(DATA_DIR, THRESHOLDS, N_EXCLUDED)
%
%   For each threshold C in THRESHOLDS, keeps the subjects who completed at
%   least C games, pools -- across exactly that fixed set of subjects -- the
%   choice steps of game #1..#C separately, and fits one beta_hat per game
%   number by grid-search MLE.
%
%   The N_EXCLUDED subjects with the most total games are dropped first: their
%   outsized step counts would otherwise dominate every pooled estimate.
%
%   Inputs (all optional)
%     DATA_DIR    folder holding fig06_steps.mat and fig06_policy.mat.
%                 Default: ../data, i.e. the repository's shared data folder.
%     THRESHOLDS  cohort thresholds. Default [20 30 40 50].
%     N_EXCLUDED  number of top players to exclude. Default 6.
%
%   Outputs
%     COHORTS  1xK struct array with fields
%                threshold   the cohort threshold C
%                games       Cx1, the game numbers 1..C
%                betas       Cx1, the fitted beta_hat per game number
%                n_subjects  number of subjects in the cohort
%                subjects    their indices into fig06_steps.mat's subject_ids
%     INFO     struct with fields excluded (indices), excluded_ids,
%              excluded_n_games, and betas (the beta grid), for reporting.
%
%   Reporting is left to the callers, so this stays usable from any figure.
%
%   See also FIT_BETA_MLE, BUILD_LOGPFLAT.

here = fileparts(mfilename('fullpath'));
if nargin < 1 || isempty(data_dir),   data_dir = fullfile(here, '..', 'data'); end
if nargin < 2 || isempty(thresholds), thresholds = [20 30 40 50];        end
if nargin < 3 || isempty(n_excluded), n_excluded = 6;                    end

S = load(fullfile(data_dir, 'fig06_steps.mat'));
P = load(fullfile(data_dir, 'fig06_policy.mat'));

betas    = P.betas(:);
logPflat = build_logPflat(P.Policy);

subject = double(S.subject(:));
game    = double(S.game(:));
state   = double(S.state(:));
action  = double(S.action(:));
n_games = double(S.n_games(:));

% 'descend' sort is stable, so ties would resolve by subject order -- as it
% happens the cut here is unambiguous (101 games vs. 81 for the 7th player).
[~, ord] = sort(n_games, 'descend');
excluded = ord(1:n_excluded);

info = struct('excluded', excluded, ...
              'excluded_ids', S.subject_ids(excluded), ...
              'excluded_n_games', n_games(excluded), ...
              'betas', betas);

cohorts = struct('threshold', cell(1, numel(thresholds)), ...
                 'games', [], 'betas', [], 'n_subjects', [], 'subjects', []);

for k = 1:numel(thresholds)
    C = thresholds(k);

    cohort = setdiff(find(n_games >= C), excluded);
    in_cohort = ismember(subject, cohort);

    beta_hats = zeros(C, 1);
    for g = 1:C
        sel = in_cohort & (game == g);
        beta_hats(g) = fit_beta_mle(state(sel), action(sel), betas, logPflat);
    end

    cohorts(k).threshold  = C;
    cohorts(k).games      = (1:C)';
    cohorts(k).betas      = beta_hats;
    cohorts(k).n_subjects = numel(cohort);
    cohorts(k).subjects   = cohort;
end
end
