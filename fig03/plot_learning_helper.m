function plot_learning_helper(data, tab_bhv, position_initial,...
    position_long_term, options, ylim)
% JN 2025-01-23

meta = data.meta;

ylabel = "Success rate";

ax1 = axes('Position', position_initial);
ax1.NextPlot = "add";

ax2 = axes('Position', position_long_term);
ax2.NextPlot = "add";

rats = 4:8;

% lmedata = cell(5, 1);

for irat = 1:5
    rat = rats(irat);
    idx = (meta.Rat == rat) & (meta.phase == "initial");
    xdata = days(meta.Date(idx) - datetime(2019, 10, 22));
    ydata = tab_bhv.frac_succ(idx);
%     ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
    plot(ax1, xdata, ydata, 'Marker', options.RatMarkers(irat), ...
        'MarkerFaceColor', options.RatColors(irat, :), ...
        'MarkerEdgeColor', options.RatColors(irat, :), ...
        'MarkerSize', options.RatMarkerSize, ...
        'LineStyle', 'none');
end

ax1.YLabel.String = ylabel;
ax1.XLabel.String = "Initial training [days]";
ax1.XLim = [0 28];
ax1.YGrid = "on";

lgd = legend(ax1, {'Rat 1', 'Rat 2', 'Rat 3', 'Rat 4', 'Rat 5'});
pos = lgd.Position;
lgd.Position(2) = pos(2) - .53;
lgd.Position(1) = pos(1) + .02;
% lgd.Color = 'none';
lgd.EdgeColor = options.LegendEdgeColor;

idx = meta.phase == "initial";
xdata = days(meta.Date(idx) - datetime(2019, 10, 22));
ydata = tab_bhv.frac_succ(idx);

p = polyfit(xdata, ydata, 1);
% plot(ax1, -1:30, polyval(p, -1:30), 'Color', 'k', ...
%     'LineWidth', options.lw_thick);

ax1.YLim = ylim;

% irats = [1 2 4 5];
% 
% ax1 = axes('Position', position_initial);
% ax1.NextPlot = "add";
% 
% ax2 = axes('Position', position_long_term);
% ax2.NextPlot = "add";
% 
% rats = 4:8;

% lmedata = cell(5, 1);
% 
% for irat = 1:5
%     rat = rats(irat);
%     idx = (meta.Rat == rat) & (meta.phase == "initial");
%     xdata = days(meta.Date(idx) - datetime(2019, 10, 22));
%     ydata = tab_bhv.frac_succ(idx);
% %     ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
%     plot(ax1, xdata, ydata, 'Marker', options.RatMarkers(irat), ...
%         'MarkerFaceColor', options.RatColors(irat, :), ...
%         'MarkerEdgeColor', options.RatColors(irat, :), ...
%         'MarkerSize', options.RatMarkerSize, ...
%         'LineStyle', 'none');
% end
% 
% ax1.YLabel.String = ylabel;
% ax1.XLabel.String = "Initial training [days]";
% ax1.XLim = [0 28];
% ax1.YGrid = "on";
% 
% lgd = legend(ax1, {'Rat 1', 'Rat 2', 'Rat 3', 'Rat 4', 'Rat 5'});
% pos = lgd.Position;
% lgd.Position(2) = pos(2) - .53;
% lgd.Position(1) = pos(1) + .02;
% lgd.Color = 'none';
lgd.EdgeColor = options.LegendEdgeColor;
irats = [1 2 4 5];
    
for irat = irats
    rat = rats(irat);
    idx = (meta.Rat == rat) & (meta.phase == "implanted");
    dates = meta.Date(idx);
    first_day = dates(1);
    xdata = days(dates - first_day);
    ydata = tab_bhv.frac_succ(idx);
    scatter(ax2, xdata, ydata, 7, ...
        'Marker', options.RatMarkers(irat), ...
        'MarkerFaceColor', options.RatColors(irat, :), ...
        'MarkerEdgeColor', options.RatColors(irat, :), ...
        'MarkerFaceAlpha', .3, ...
        'MarkerEdgeAlpha', .3);
%         'LineStyle', 'none', ...
    % plot weekly averages of each line
    plot(ax2, xdata, movmean(ydata, 28), 'LineStyle', '-', ...
        'Color', options.RatColors(irat, :), 'LineWidth', 2);
      fprintf('Rat %d up to day %d\n', rat, xdata(end));
end


ax2.YGrid = "on";
% ax.YLim = [0 8000];
ax2.XLabel.String = "Implanted period [days]";
ax2.XLim = [0 415];
ax2.YLim = ylim;

% insert the analysis time periods
ymin = ylim(1);
ygap = .04;
l = ax2.XLim(2);
starts = [0 50 150];
for i = 1:3
    f = starts(i);
    % ymax = ymin + ygap;
    % patch(ax2, [f l l f], [ymin ymin ymax ymax], .5 * [1 1 1], ...
        % 'FaceAlpha', .5, 'EdgeColor', 'none')
    % xline(ax1, f, 'LineWidth', 2);
    xline(ax2, f, 'LineWidth', 1.5, 'Color', .1 * [1 1 1]);
    % text(ax2, f, ax2.YLim(2), sprintf('%i ↦', i), 'VerticalAlignment','middle')
    % ymin = ymin + ygap;

end

ax1.YTick = ax1.YTick(1:2:end);

ax2.YTick = ax2.YTick(1:2:end);