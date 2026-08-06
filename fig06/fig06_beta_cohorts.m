function [ax, tbl, key_ax] = fig06_beta_cohorts(pos, cohorts, options)
% JN 2026-08-03
% Panel F of figure 6: beta_hat per game number, four cohorts in one panel.
%
%   AX = FIG06_BETA_COHORTS(POS, COHORTS, OPTIONS) draws into a new axes at
%   normalized position POS = [left bottom width height].
%
%   [AX, TBL] = FIG06_BETA_COHORTS(...) also returns a table with one row per
%   plotted point and the columns cohort (the threshold), game and beta_hat.
%   It is built from the very vectors that are plotted, so it can serve as the
%   numerical reference for the panel: statistics quoted from the figure can be
%   checked against it without re-running COMPUTE_COHORT_BETAS on raw data.
%   Writing it to disk is left to the caller.
%
%   [AX, TBL, KEY_AX] = FIG06_BETA_COHORTS(...) also returns the axes holding
%   the colour key. The key is a plain image axes rather than a COLORBAR, so
%   its position and ticks are set explicitly and a fig06 driver can move or
%   restyle it without fighting MATLAB's automatic layout. Its geometry is
%   KEY_REL below, given as fractions of POS.
%
%   COHORTS is the struct array from COMPUTE_COHORT_BETAS. Each cohort becomes
%   one group along x, separated by gaps; within a group every game is one
%   point, plotted one next to the other in game order. Group width therefore
%   encodes cohort size (20, 30, 40, 50 games). A dashed line per group marks
%   its mean.
%
%   The message: beta is flat within a cohort (no within-session learning) but
%   steps up between cohorts (subjects who play more games have higher beta).
%
%   Designed to be legible at ~1/6 of an A4 page, which is the size FIG06 gives
%   it. The font sizes below are therefore deliberately absolute and smaller
%   than options.LabelSize; do not raise them.
%
%   See also COMPUTE_COHORT_BETAS, FIG06_BETA_COHORT_STATS.

% Sizes are tuned for a ~1/6-A4 panel, so they are deliberately smaller than
% options.LabelSize (13), which is calibrated for full-width panels.
label_size = 9;
tick_size = 8;
gap = 12;                % x units between groups
markerarea = 8;         % points^2, as scatter wants it

% Colour encodes game number on a scale shared by all groups: game 1 has the
% same colour everywhere, and only the widest cohort reaches the bright end, so
% the ramp itself shows that the later cohorts play more games. The encoding is
% redundant with x within a group, but the key below still names the scale.
% A two-anchor ramp is used rather than parula: over the ~20 games of
% the narrowest cohort, parula's slice was too uniform to read as a progression.
% The anchors span both hue and lightness, so the ramp survives greyscale, and
% neither end is pale enough to vanish against white at this marker size. Blue
% to cyan rather than black to grey, so the dots stay clear of the grey mean
% lines below; swap the anchors here to change the ramp.
c_first = [.05 .05 .45];   % game 1
c_last  = [.10 .80 .90];   % game g_max
g_max = max([cohorts.threshold]);
cmap = c_first + (c_last - c_first) .* linspace(0, 1, g_max)';

ax = axes('Position', pos);
ax.NextPlot = "add";

n = numel(cohorts);
centres = zeros(1, n);
labels = cell(1, n);

cohort_col = [];
game_col = [];
beta_col = [];

x0 = 0;
for k = 1:n
    C = cohorts(k).threshold;
    g = cohorts(k).games;
    x = x0 + g;
    y = cohorts(k).betas;

    scatter(ax, x, y, markerarea, cmap(g, :), 'filled', ...
            'MarkerEdgeColor', 'none');
    % Neutral, so the mean reads as an annotation rather than as more data.
    plot(ax, [x(1) x(end)], mean(y) * [1 1], '-', ...
         'Color', .25 * [1 1 1], 'LineWidth', 1);

    cohort_col = [cohort_col; repmat(C, numel(g), 1)];
    game_col = [game_col; g];
    beta_col = [beta_col; y];

    centres(k) = mean(x);
    labels{k} = sprintf('\\geq%d\\newlineN=%d', C, cohorts(k).n_subjects);

    % Faint divider in the gap: colour no longer separates the groups at all,
    % and the groups have different widths.
    if k < n
        xline(ax, x(end) + gap / 2, 'Color', .85 * [1 1 1], 'LineWidth', .5);
    end

    x0 = x0 + C + gap;
end

tbl = table(cohort_col, game_col, beta_col, ...
            'VariableNames', {'cohort', 'game', 'beta_hat'});

ax.XLim = [-2, x0 - gap + 2];
ax.XTick = centres;
ax.XTickLabel = labels;

% Lower limit below zero on purpose: one game in the >=50 cohort fits at the
% 1e-6 grid boundary and would otherwise hide inside the axis line.
ax.YLim = [-0.015 0.37];
ax.YTick = 0:.1:.3;

% Names what a point's x position means; the tick labels name the cohorts.
% ax.XLabel.String = 'game number within cohort';
ax.YLabel.String = 'Estimated \beta';
ax.XLabel.FontSize = label_size;
ax.YLabel.FontSize = label_size;
ax.FontSize = tick_size;

ax.YGrid = "on";
ax.Box = "off";
ax.TickLength = [.015 .015];

%% ------------------------------------------------------------- colour key
% Deliberately not COLORBAR: that would resize the main axes and place itself,
% and the position would then have to be fought back. This is a bare image
% axes, so every coordinate below is explicit and stays put.
%
% KEY_REL is [left bottom width height] as fractions of the panel's own POS
% box. It sits in the panel's upper left, which is empty: the two narrow
% cohorts on the left top out well below beta = 0.2. Move it here.
key_rel = [.05 .92 .34 .04];
key_pos = [pos(1) + key_rel(1) * pos(3), pos(2) + key_rel(2) * pos(4), ...
           key_rel(3) * pos(3), key_rel(4) * pos(4)];

key_ax = axes('Position', key_pos);

% 1 x g_max truecolor strip: one pixel per game, so the key shows exactly the
% colours the dots are drawn with, with no resampling.
image(key_ax, 'XData', [1 g_max], 'YData', [0 1], ...
      'CData', permute(cmap, [3 1 2]));

key_ax.XLim = [.5, g_max + .5];
key_ax.YLim = [0 1];
key_ax.YTick = [];
key_ax.XTick = [1 g_max];
key_ax.TickLength = [0 0];
key_ax.FontSize = tick_size - 1;
key_ax.Box = "on";
key_ax.XColor = .3 * [1 1 1];
key_ax.YColor = .3 * [1 1 1];
key_ax.LineWidth = .5;

key_ax.Title.String = 'Game number';
key_ax.Title.FontSize = tick_size - 1;
key_ax.Title.FontWeight = "normal";
key_ax.Title.Color = .3 * [1 1 1];

% Leave the data axes current, so a caller can keep drawing into the panel.
set(gcf, 'CurrentAxes', ax);
end
