function fig05_plot_correlations(pos, S, options)
% JN 2023-09-14
% JN 2025-01-21 change back to one above the other again

w_pos = pos(3);
h_pos = pos(4);

% rel_w_left = .4;
rel_w_left = 1;
% rel_w_right = .4;
rel_h_left = .5;
vgap = .02;

abs_w_left = w_pos * rel_w_left;
% abs_w_right = w_pos * rel_w_right;
abs_h_left = h_pos * rel_h_left;

pos_left_top = [pos(1) pos(2) + pos(4) - abs_h_left + vgap abs_w_left abs_h_left];
pos_left_bot = [pos(1) pos(2) abs_w_left abs_h_left];
% pos_left_top = [pos(1) pos(2) abs_w_left, pos(4) * .8];
% pos_right = [pos(1) + pos(3) - abs_w_right pos(2) abs_w_right pos(4)];

ax1 = axes('Position', pos_left_bot);
% ax2 = axes('Position', pos_left_bot);
ax3 = axes('Position', pos_left_top);

own_corr = S.all_corr(S.own_mask);
other_corr = S.all_corr(~(S.own_mask));
binlen = 0.05;
bins = -1:binlen:1;

own_cnts = histcounts(own_corr(:), bins, 'Normalization', 'probability');
other_cnts = histcounts(other_corr(:), bins, 'Normalization', 'probability');
ax1.NextPlot = "add";
[t_cnts, ~] = histcounts(other_corr, bins, 'Normalization', 'probability');
l1 = plot(ax1, bins(1:end-1) + binlen/2, t_cnts, 'LineWidth', 2, 'Color', 'k');

h1 = histogram(ax1, own_corr, bins, 'EdgeColor', 'none', 'FaceColor', ...
    options.HistogramFaceColor, 'Normalization', 'probability', 'FaceAlpha', .7);
% histogram(ax2, other_corr, bins, 'EdgeColor', 'none', 'FaceColor', ...
%     options.HistogramFaceColor, 'Normalization', 'probability', 'FaceAlpha', 1);
lgd = legend(ax1, ["Other session" "Same session"]);
lgd.EdgeColor = .8 * [1 1 1];
% lgd.Position(2) = lgd.Position(2) + .07;
lgd.Position = [0.31, 0.26, 0.15,0.03];
ldata = log10(own_cnts ./ other_cnts);

n_bars = size(ldata, 2);

for i = 1:n_bars
    x = bins(i);
    y = ldata(i);
    patch(ax3, [x x+binlen x+binlen x], [0 0 y y], [0 0 y y], 'edgecolor', [1 1 1] * .7)    
end

colormap(ax3, redblue())
clim([-.6 .6]);
ax3.YLim = [-.3, 1];

all_ax = {ax1, ax3};

for iax = 1:2
    all_ax{iax}.XGrid = "on";
    all_ax{iax}.Box = "off";
    all_ax{iax}.Layer = 'bottom';
end

for iax = 1:2
    all_ax{iax}.XTick = -1:.2:1;
    all_ax{iax}.XTickLabelRotation = 90;
end

for iax = 1
    all_ax{iax}.YLabel.String = "Probability";
end

% ax1.XTickLabel = [];

% text(ax1, .5, 1.35, "Correlation", ...
%     'FontWeight', 'bold', ...
%     'Units', 'normalized', 'HorizontalAlignment', 'center');
% 
% text(ax1, .5, 1.29, "\beta ~ firing rates", ...
%     'FontWeight', 'bold', ...
%     'Units', 'normalized', 'HorizontalAlignment', 'center');

% text(ax1, .05, 1.1, "Same sess", 'Units', 'normalized', ...
%     'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
% 
% text(ax2, .05, 1.1, "Diff. sess.", 'Units', 'normalized', ...
%     'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');


ax1.XLabel.String = "Correlation coefficient";
% ax3.XLabel.String = "Correlation coefficient";
% ax2.XAxis.FontSize = 6;
ax3.YLabel.String = "Log likelihood";
ax3.XTickLabel = [];
% ax3.Title.String = "Same vs. different session";
% ax3.Title.FontWeight = "normal";

