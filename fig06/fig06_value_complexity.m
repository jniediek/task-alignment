function ax = fig06_value_complexity(pos, options)
% JN 2026-08-05
% Panel B of figure 6: value against information complexity over the beta grid.
%
%   AX = FIG06_VALUE_COMPLEXITY(POS, OPTIONS) draws into a new axes at the
%   normalized position POS = [left bottom width height].
%
%   The rate-distortion trade-off of the guessing-game MDP: every point is one
%   beta, at the complexity its policy costs and the value it achieves. The
%   curve is concave, so the return on complexity falls off as beta grows.
%
%   This is the same plot FIG02_C draws for the maze MDP, deliberately in the
%   same idiom -- one analysis applied to two tasks -- and it is the MATLAB
%   version of gg_figures/code/fig10_warm_start_value_complexity.py.
%
%   Value and Complexity are read from ../data/fig06_policy.mat. They cannot be
%   computed from the Policy tensor there, which carries neither a reward nor a
%   discount; they come from the solver that produced the policies. See
%   gg_figures/export/export_to_mat.py.

% Sizes tuned for a ~1/6-A4 panel, as in FIG06_BETA_COHORTS.
label_size = 9;
tick_size = 8;

% Only the two curves, not the 7.6 MB policy tensor in the same file.
S = load('../data/fig06_policy.mat', 'betas', 'Value', 'Complexity');
x_info = S.Complexity;
y_value = S.Value;

% Both are monotone in beta, so the points already come in x order and the
% argsort the Python reference applies is a no-op. No sort here.

ax = axes('Position', pos);
ax.NextPlot = "add";

% Fill first, so the line draws on top of it. No fill_between in MATLAB: close
% the polygon along the bottom of the axes by hand, as fig02_c does.
y_floor = min(y_value);
fill(ax, [x_info; x_info(end); x_info(1)], [y_value; y_floor; y_floor], 'y', ...
    'FaceAlpha', .5, 'EdgeColor', 'none');

plot(ax, x_info, y_value, 'LineWidth', 1.5, 'Color', [.10 .54 .24]);

ax.XLabel.String = 'I(\pi)';
ax.YLabel.String = 'Value';
ax.XLabel.FontSize = label_size;
ax.YLabel.FontSize = label_size;
ax.FontSize = tick_size;

ax.XLim = [min(x_info) max(x_info)];
ax.YLim = [y_floor max(y_value)];

ax.Box = "off";
ax.TickLength = [.015 .015];

% The four policies panel C draws, marked on the curve as fig02_c marks its own
% four, with the same dot size. Clipping off so the first dot, which sits
% exactly on the y axis at I(pi) = 0, is not cut in half.
%
% The beta legend is stacked in the upper left, which the curve leaves empty,
% and laid out as panel C's, so the two legends read the same way. This axes is
% about 2.5 times as tall as one of panel C's, so the normalized line spacing
% is scaled down to give the same spacing on the page.
n_pol = numel(options.pol_nums);
line_step = .13 * .4;
for i = 1:n_pol
    k = options.pol_nums(i);
    plot(ax, x_info(k), y_value(k), '.', 'MarkerSize', 20, ...
        'Color', options.TitleColors(i, :), 'Clipping', 'off');

    text(ax, .05, .96 - (n_pol - i) * line_step, ...
        sprintf('\\beta = %.2f', S.betas(k)), 'Units', 'normalized', ...
        'Color', options.TitleColors(i, :), 'FontSize', tick_size, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
end
