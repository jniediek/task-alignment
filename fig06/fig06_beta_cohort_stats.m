% JN 2026-08-04
% Statistics backing panel F of figure 6 (see FIG06_BETA_COHORTS).
%
% Refits the cohorts through COMPUTE_COHORT_BETAS, i.e. the very code panel F
% is drawn from, so the two cannot drift apart: 140 rows, one row per
% (cohort, game number), each row a single beta_hat pooled by grid-search MLE
% over every choice step that cohort's subjects took at that game number.
%
% Two claims are tested:
%   (1) beta_hat has no linear trend across game number within a cohort;
%   (2) the cohorts differ from one another.
%
% Note throughout that a row is a pooled estimate, not a subject, so n = 140 is
% not 140 independent observations and the residual df of the linear models
% below is not a real degrees of freedom. That is why every p-value here comes
% from a permutation, and why the parametric anova p-values in the commented-out
% block below must not be quoted.
%
% Note also that the cohorts are nested: >=50 subset of >=40 subset of >=30
% subset of >=20. See the cohort-permutation section for what that costs.

rng(20260804, 'twister');   % so the printed p-values are reproducible

cohorts = compute_cohort_betas();

cohort_col = [];
game_col = [];
beta_col = [];
for k = 1:numel(cohorts)
    cohort_col = [cohort_col; repmat(cohorts(k).threshold, numel(cohorts(k).games), 1)];
    game_col = [game_col; cohorts(k).games];
    beta_col = [beta_col; cohorts(k).betas];
end

tbl = table(cohort_col, game_col, beta_col, ...
    'VariableNames', {'cohort', 'game', 'beta_hat'});
tbl.cohort = categorical(tbl.cohort);

% %% full model
% lm=fitlm(tbl,'beta_hat~cohort*game')
% anova(lm)
% %% no interaction
% lmn=fitlm(tbl,'beta_hat~cohort+game')
% anova(lmn)
% %% Compare the two models:
% % comparison is non-significant, therefore the model without interaction is
% % correct
% chi2cdf(2*(lm.LogLikelihood-lmn.LogLikelihood),1,'upper')
%
% % result: approx 0.34
%% Check game effect in the first 20 games in each cohort
% use permutations to obtain a null F distribution
% Idea: restricting ourselves to the first 20 games allows to apply
% an identical permutation to each set of 20 games (across cohorts).
% Because the same permutation is applied everywhere, the cohort means are
% untouched and only a trend in game number is destroyed.
% If there was any significant trend of beta hat as a function of game,
% this permutation would destroy the trend. The observed F would then be
% larger than almost all F under permutation.
%
% However, ~25% of the permuted Fs are above the original F, so there is no evidence of a linear
% trend in the 20 first games.
%
% This is also the clearest illustration of why the parametric p-values are not
% usable here: the observed F = 3.44 on a nominal (1, 135) would give p = 0.066,
% which would read as a marginal trend, against p = 0.25 by permutation. The
% nominal residual df counts pooled estimates as if they were independent
% observations, and it is wrong by enough to matter.


numPermutations = 1000;
Nrestrict = 20;

nullF20 = zeros(numPermutations, 1);

% Restrict the table to the first 20 games
tbl20 = tbl(tbl.game <= Nrestrict, :);
% Calculate the observed F statistic from the original model
lm20 = fitlm(tbl20, 'beta_hat~cohort+game');
observedan20 = anova(lm20);
assert(strcmp(observedan20.Row{2}, 'game'));
observedF20 = observedan20.F(2);


for i = 1:numPermutations
    perm = randperm(Nrestrict)';
    permtab = tbl20;
    for coh = [20 30 40 50]
        idx = tbl20.cohort == categorical(coh);
        assert(all(tbl20.game(idx)' == 1:20))
        permtab.game(idx) = perm;
    end
    lmPerm = fitlm(permtab, 'beta_hat~cohort+game');
    an = anova(lmPerm);
    assert(strcmp(an.Row{2}, 'game'));
    nullF20(i) = an.F(2); % Store the F statistic for the permutation
end

p20 = (1 + sum(nullF20 >= observedF20))/(numPermutations + 1);
fprintf('Game effect, first 20 games of every cohort: F = %.3f, P = %.5f (permutation)\n', ...
    observedF20, p20);

%% next, we use the full data again
% Here the idea is to permute games 1-20 in each cohort together,
% then 21-30 in the remaining cohorts together, etc; and then run the same
% as above, but on the full data.
%
% The block structure means the four block means (games 1-20, 21-30, 31-40,
% 41-50) are identical in every permuted data set, so this tests for a trend
% *within* the blocks only. A step between blocks would survive into the null
% and could not be detected here. That is the price of keeping the permutation
% applicable across cohorts of different width.
% numPermutations = 1000;

numPermutations = 1000;

nullFall = zeros(numPermutations, 1);

% redo the anova from above (for stability against later code changes above)
lmall = fitlm(tbl, 'beta_hat~cohort+game');
observedanall = anova(lmall);
assert(strcmp(observedanall.Row{2}, 'game'));
observedFall = observedanall.F(2);

startstop = [[1 20]; [21 30]; [31 40]; [41 50]];

for i = 1:numPermutations
    permtab = tbl;
    for i_coh = 1:4
        start = startstop(i_coh, 1);
        stop = startstop(i_coh, 2);
        base = (start:stop)';
        perm = base(randperm(length(base)));

        for j_coh = i_coh:4
            coh = startstop(j_coh, 2);
            idx = permtab.cohort == categorical(coh);
            idx = idx & (permtab.game >= start) & (permtab.game <= stop);
            assert(all(permtab.game(idx)' == start:stop))
            permtab.game(idx) = perm;
        end
    end
    lmPerm = fitlm(permtab, 'beta_hat~cohort+game');
    an = anova(lmPerm);
    assert(strcmp(an.Row{2}, 'game'));
    nullFall(i) = an.F(2); % Store the F statistic for the permutation
end
pall = (1 + sum(nullFall >= observedFall))/(numPermutations + 1);

fprintf('Game effect, all games (blockwise permutation): F = %.3f, P = %.3g (permutation)\n', ...
    observedFall, pall);

% This is the same hypothesis as the section above, on more data -- the two are
% nested analyses of one question, not two independent confirmations.

%% histogram of nullFall
% The reference density is the F the parametric model would assume. It is drawn
% as a diagnostic only: with pooled estimates rather than subjects as rows, the
% nominal df below are not real degrees of freedom, so a mismatch between the
% curve and the histogram is expected and is itself the reason for permuting.
figure;
h = histogram(nullFall, 100, 'Normalization', 'pdf');
hold on

x = linspace(h.BinEdges(1), h.BinEdges(end), 500);
plot(x, fpdf(x, observedanall.DF(2), lmall.DFE), 'LineWidth', 2);
xline(observedFall);

hold off
title('Null F for the game term (blockwise permutation)');

%% next, check the difference in means between cohorts
% Here the idea is to permute cohort id within each game number. That preserves
% each cohort's range of game numbers exactly (only cohorts >= g have a row at
% game g), so the cohort/game confound is preserved rather than destroyed, and
% the row count per cohort is unchanged.
%
% CAVEAT, and it is not a small one: the cohorts are nested, so the rows being
% exchanged at a given game number are computed from overlapping subjects and
% are strongly positively correlated; and they differ in precision by an order
% of magnitude (222 pooled subjects for >=20 against 20 for >=50). Exchangeability
% under the null therefore fails on both counts, and this P value is approximate.
% The two game-effect sections above are not affected: they permute within a
% cohort, and within a cohort every game pools the same set of subjects.
%
% Note also that this F is omnibus. It tests whether the cohorts differ, not
% whether beta_hat increases with the number of games played.

lmcoh = fitlm(tbl, 'beta_hat~cohort+game');
observedancoh = anova(lmcoh);
assert(strcmp(observedancoh.Row{1}, 'cohort'));
observedFcoh = observedancoh.F(1);


numPermutations = 1000;

nullFcoh = zeros(numPermutations, 1);
maxgame = max(tbl.game);



% the loop below creates one permuted table


for i = 1:numPermutations
    permtab_coh = tbl;
    for ig = 1:maxgame
        g_idx = tbl.game == ig;
        if sum(g_idx) < 2
            continue
        end
        in_dat = tbl.cohort(g_idx);
        permtab_coh.cohort(g_idx) = in_dat(randperm(length(in_dat)));
    end
    lmPerm = fitlm(permtab_coh, 'beta_hat~cohort+game');
    an = anova(lmPerm);
    assert(strcmp(an.Row{1}, 'cohort'));
    nullFcoh(i) = an.F(1);
end

figure;
h = histogram(nullFcoh, 100, 'Normalization', 'pdf');
hold on

x = linspace(h.BinEdges(1), h.BinEdges(end), 500);
plot(x, fpdf(x, observedancoh.DF(1), lmcoh.DFE), 'LineWidth', 2);
xline(observedFcoh);

hold off
title('Null F for the cohort term (cohort permuted within game)');

pcoh = (1 + sum(nullFcoh >= observedFcoh))/(numPermutations + 1);

fprintf('Cohort effect (cohort permuted within game): F = %.3f, P = %.3g (permutation)\n', ...
   observedFcoh, pcoh);

% Descriptive, to accompany the omnibus test: the cohort means in order.
fprintf('Cohort means, in cohort order:');
for coh = [20 30 40 50]
    fprintf(' >=%d: %.4f', coh, mean(tbl.beta_hat(tbl.cohort == categorical(coh))));
end
fprintf('\n');

%% per-cohort slope of beta_hat on game number, with bootstrap CI
% One ordinary least-squares slope per cohort, and a percentile confidence
% interval from resampling that cohort's own (game, beta_hat) rows with
% replacement -- a pairs bootstrap.
%
% What this interval covers: the scatter of the points that are actually drawn
% in panel F. What it does NOT cover: the estimation uncertainty of each
% individual beta_hat. Propagating that would mean resampling *subjects* within
% the cohort and re-running FIT_BETA_MLE for every game number, which needs
% data/steps.mat and data/policy.mat. So this is not a subject-level interval
% and must not be quoted as one.
%
% The slope is also reported as the implied change across the whole cohort, in
% units of the beta grid spacing. The grid is linspace(1e-6, 2, 200), i.e. steps
% of ~0.01005, and every beta_hat is exactly one of those grid points -- over the
% observed range of ~0.04 to 0.30 there are only about 25 attainable values. A
% trend smaller than a grid step over the width of a cohort is not something
% these estimates could resolve in the first place, which is the honest way to
% read a null result here.

nBoot = 1000;
grid_step = 2 / 199;              % spacing of linspace(1e-6, 2, 200)
cohort_list = [20 30 40 50];

fprintf('\nPer-cohort slope of beta_hat on game number (pairs bootstrap, %d resamples):\n', ...
    nBoot);

for k = 1:numel(cohort_list)
    idx = tbl.cohort == categorical(cohort_list(k));
    g = double(tbl.game(idx));
    y = tbl.beta_hat(idx);
    C = numel(g);

    p = polyfit(g, y, 1);
    slope = p(1);

    bs = zeros(nBoot, 1);
    for b = 1:nBoot
        r = randi(C, C, 1);
        % A resample can in principle draw fewer than two distinct game
        % numbers, and the line fit is then undefined. Negligible at C >= 20,
        % but redraw rather than emit a rank-deficiency warning.
        while numel(unique(g(r))) < 2
            r = randi(C, C, 1);
        end
        pb = polyfit(g(r), y(r), 1);
        bs(b) = pb(1);
    end
    ci = prctile(bs, [2.5 97.5]);

    if ci(1) <= 0 && ci(2) >= 0
        verdict = 'covers zero';
    else
        verdict = 'EXCLUDES zero';
    end

    % Total change implied over the cohort's own range of game numbers, in
    % units of the beta grid step -- the scale on which "flat" is meaningful.
    span = (max(g) - min(g));
    fprintf(['  >=%2d games (%2d points): slope = %+9.2e / game, ' ...
             '95%% CI [%+9.2e, %+9.2e] (%s);\n' ...
             '                          total change over games %d-%d = ' ...
             '%+.4f = %+.2f grid steps\n'], ...
        cohort_list(k), C, slope, ci(1), ci(2), verdict, ...
        min(g), max(g), slope * span, slope * span / grid_step);
end
