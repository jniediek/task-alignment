function [ax, model_tbl, human_tbl] = fig06_beta_vs_avg_steps(pos, data_dir, options)
%FIG06_BETA_VS_AVG_STEPS  Panel E of figure 6: model vs. human, beta against
%   average game length.
%
%   AX = FIG06_BETA_VS_AVG_STEPS(POS, DATA_DIR, OPTIONS) draws into a new axes
%   at normalized position POS = [left bottom width height].
%
%   [AX, MODEL_TBL, HUMAN_TBL] = FIG06_BETA_VS_AVG_STEPS(...) also returns the
%   plotted values: MODEL_TBL with columns beta, mean_steps, sd_steps, band_lo,
%   band_hi (one row per beta), and HUMAN_TBL with columns subject_id, beta_hat, avg_steps (one
%   row per subject). Both are built from the very vectors that are plotted, so
%   they serve as the numerical reference for the panel. Writing them to disk
%   is left to the caller.
%
%   Inputs (all optional)
%     POS       normalized axes position. Default [.14 .17 .83 .79].
%     DATA_DIR  folder holding fig06_steps.mat and fig06_policy.mat.
%               Default: ../data, the repository's shared data folder.
%     OPTIONS   struct from GET_OPTIONS. Loaded if omitted.
%
%   MATLAB port of code/fig02_beta_vs_avg_steps_simulation.py, by way of
%   code/fig02_variant_exact_avg_steps.py.
%
%   THE MODEL CURVE IS EXACT, NOT SIMULATED
%   ---------------------------------------
%   The Python original estimates the curve by simulating 1000 games per beta.
%   EXACT_STEPS_MOMENTS computes the same quantity in closed form instead --
%   see its help for why one forward sweep suffices. That removes the sampling
%   noise visible in the original PNG, and it is what makes this panel
%   reproducible against Python at all: two different RNGs never agree, two
%   evaluations of the same recursion do.
%
%   THE BAND IS FOR A SUBJECT'S AVERAGE, NOT FOR ONE GAME
%   -----------------------------------------------------
%   Each dot is a subject's mean over n games, which scatters around the model
%   mean by SD/sqrt(n), not by the per-game SD. A +/- 1 SD band would hold
%   every subject whether or not the model fits. The band is therefore
%   mean +/- 1.96 SD/sqrt(n), the central 95% range of an n-game average under
%   the model, normal by the central limit theorem (n >= 21 for every subject).
%   It is not a confidence interval: the curve is exact. n is the median
%   number of games, floored to a whole game, so the band is exact only for
%   the typical subject; the per-subject check, which uses each subject's own
%   n, is printed as z scores (see below) and belongs in the caption.
%
%   The Python variant instead draws sd/sqrt(1000) error bars, purely so its
%   PNG stays visually comparable with the Monte Carlo original it replaces.
%
%   The message: humans with a higher fitted beta finish games in fewer
%   guesses, tracking the model curve, and essentially nobody beats it.
%
%   See also EXACT_STEPS_MOMENTS, FIT_SUBJECT_BETAS.

here = fileparts(mfilename('fullpath'));
if nargin < 1 || isempty(pos),      pos = [.14 .17 .83 .79];              end
if nargin < 2 || isempty(data_dir), data_dir = fullfile(here, '..', 'data'); end
if nargin < 3 || isempty(options)
    addpath(fullfile(here, '..', 'common'));
    options = get_options();
end

% Sizes tuned for a ~1/6-A4 panel, deliberately smaller than options.LabelSize
% (13), which is calibrated for full-width panels. Matches fig06_beta_cohorts.
label_size = 9;
tick_size = 8;
markerarea = 6;             % points^2, as scatter wants it

% Carried over from the Python original so the two renderings are recognisably
% the same figure: warm red for the subjects, near-black for the model.
c_human = [.906 .298 .235];
c_model = [.173 .243 .314];

%% ------------------------------------------------------------------- data
P = load(fullfile(data_dir, 'fig06_policy.mat'), 'betas', 'Policy');

betas = P.betas(:);
[mean_steps, sd_steps] = exact_steps_moments(P.Policy);

% One beta_hat per subject, from the same helper panel D selects its examples
% with, so the two panels cannot disagree about a subject.
fits = fit_subject_betas(data_dir);

human_beta = [fits.beta_hat]';
% Mean guesses per game. fig06_steps.mat holds one row per choice step and
% n_games per subject, so this is exactly Python's
% len(choice_steps) / count_total_games(steps).
n_games = [fits.n_games]';
human_avg = [fits.n_steps]' ./ n_games;

% Floored so the label names a whole number of games; the median of an even
% number of subjects can fall between two.
n_band = floor(median(n_games));
half_width = 1.96 * sd_steps / sqrt(n_band);
band_lo = mean_steps - half_width;
band_hi = mean_steps + half_width;

% Per-subject standardized residual against the model at that subject's
% beta_hat, with the subject's own number of games. If the model explains the
% scatter, z is roughly standard normal: SD near 1, 95% within +/- 1.96.
z = (human_avg - interp1(betas, mean_steps, human_beta)) ./ ...
    (interp1(betas, sd_steps, human_beta) ./ sqrt(n_games));
fprintf(['Panel E: band for n = %g games (median); z over %d subjects: ' ...
         'mean %.2f, SD %.2f, %.1f%% within +/-1.96, %.1f%% below, ' ...
         '%.1f%% above\n'], n_band, numel(z), mean(z), std(z), ...
        100 * mean(abs(z) <= 1.96), 100 * mean(z < -1.96), ...
        100 * mean(z > 1.96));

model_tbl = table(betas, mean_steps, sd_steps, band_lo, band_hi, ...
                  'VariableNames', {'beta', 'mean_steps', 'sd_steps', ...
                                    'band_lo', 'band_hi'});
human_tbl = table([fits.subject_id]', human_beta, human_avg, ...
                  'VariableNames', {'subject_id', 'beta_hat', 'avg_steps'});

%% ------------------------------------------------------------------- plot
ax = axes('Position', pos);
ax.NextPlot = "add";

% Band first, so the subjects and the mean line sit on top of it.
fill(ax, [betas; flipud(betas)], ...
     [band_lo; flipud(band_hi)], ...
     c_model, 'FaceAlpha', .12, 'EdgeColor', 'none');

scatter(ax, human_beta, human_avg, markerarea, c_human, 'filled', ...
        'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', .75);

plot(ax, betas, mean_steps, '-', 'Color', c_model, 'LineWidth', 1.2);

ax.XLim = [-.05 2.05];
ax.XTick = 0:.5:2;

% Wide enough for the whole subject cloud (5.33 .. 9.04 on the shipped data)
% with a little air; the band never leaves this range.
ax.YLim = [5 9.5];
ax.YTick = 5:9;

ax.XLabel.String = 'Estimated \beta';
ax.YLabel.String = 'Guesses per game';
ax.XLabel.FontSize = label_size;
ax.YLabel.FontSize = label_size;
ax.FontSize = tick_size;

ax.YGrid = "on";
ax.Box = "off";
ax.TickLength = [.015 .015];

% Hand-placed rather than LEGEND: at this panel size the automatic box eats
% the upper right, which is where the subject cloud thins out and the model
% curve has to stay readable. Same reasoning as the colour key in
% fig06_beta_cohorts.m.
text(ax, 1.98, 9.15, 'Human subjects', 'Color', c_human, ...
     'FontSize', tick_size, 'HorizontalAlignment', 'right');
text(ax, 1.98, 8.75, sprintf('Model, 95%% range (n = %g)', n_band), ...
     'Color', c_model, ...
     'FontSize', tick_size, 'HorizontalAlignment', 'right');
end
