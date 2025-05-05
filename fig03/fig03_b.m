% JN 2023-08-29
function ax = fig03_b(position, data, options, ylim)

if strcmp(options.target_var, 'TC')
    use_tc = true;
    ymin = 0;
    ymax = 8000;
    %     top_ylabel = "D_{KL}(rat estim. ‖ default)";
elseif strcmp(options.target_var, 'beta')
    use_tc = false;
    ymin = 0.05;
    ymax = 0.15;
    %     top_ylabel = "\beta";
else
    error('target var has to be TC or beta')
end

ax = axes('Position', position);
ax.NextPlot = "add";

use_param = 1;
meta = data.meta;
LL_imax_all_opt = data.LL_imax_all_opt;

% first mark the first 28 days and the last 28 days in each rat

rats = 4:8;
irats = [1 2 4 5];
% patch([0 28 28 0], [ymin ymin ymax ymax], [.5 .5 .5], 'FaceAlpha', .2, ...
%     'EdgeColor', 'none')
% 
% for irat = irats
%     rat = rats(irat);
%     idx = (meta.Rat == rat) & (meta.phase == "implanted");
%     dates = meta.Date(idx);
%     first_day = dates(1);
%     xdata = days(dates - first_day);
%     l = xdata(end);
%     f = l - 28;
%     patch([f l l f], [ymin ymin ymax ymax], options.RatColors(irat, :), ...
%         'FaceAlpha', .4, 'EdgeColor', 'none');
% end
%
% text(.5, 1.15, "Implanted period", 'FontSize', 7, ...
%     'Color', .2 * [1 1 1], 'Units', 'normalized', ...
%     'HorizontalAlignment', 'center')
% 
% text(0, 1.1, 'First month', 'FontSize', 7, ...
%     'Color', .2 * [1 1 1], 'Units', 'normalized', ...
%     'HorizontalAlignment', 'center')
% 
% text(.7, 1.1, "Last months", 'FontSize', 7, ...
%     'Color', .2 * [1 1 1], 'Units', 'normalized', 'HorizontalAlignment', ...
%     'center');

for irat = irats
    rat = rats(irat);
    idx = (meta.Rat == rat) & (meta.phase == "implanted");
    dates = meta.Date(idx);
    first_day = dates(1);
    xdata = days(dates - first_day);
    if use_tc
        ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
    else
        ydata = data.betas(LL_imax_all_opt(idx))';
    end
    scatter(ax, xdata, ydata, 7, ...
        'Marker', options.RatMarkers(irat), ...
        'MarkerFaceColor', options.RatColors(irat, :), ...
        'MarkerEdgeColor', options.RatColors(irat, :), ...
        'MarkerFaceAlpha', .3, ...
        'MarkerEdgeAlpha', .3);
    %         'LineStyle', 'none', ...
    % plot weekly averages of each line
    plot(ax, xdata, movmean(ydata, 28), 'LineStyle', '-', ...
        'Color', options.RatColors(irat, :), 'LineWidth', 2);
    fprintf('Rat %d up to day %d\n', rat, xdata(end));
end

ax.YGrid = "on";
ax.YLim = [ymin ymax];

if options.plot_xlabel
    ax.XLabel.String = "Implanted period [days]";
end

ax.XLim = [0 415];
ax.YLim = ylim;
starts = [0 50 150];
for i = 1:3
    f = starts(i);
    % ymax = ymin + ygap;
    % patch(ax2, [f l l f], [ymin ymin ymax ymax], .5 * [1 1 1], ...
        % 'FaceAlpha', .5, 'EdgeColor', 'none')
    % xline(ax1, f, 'LineWidth', 2);
    xline(ax, f, 'LineWidth', 1.5, 'Color', .1 * [1 1 1]);
    text(ax, f, ax.YLim(2), sprintf(' %i ↦', i), 'VerticalAlignment', 'top')
    % ymin = ymin + ygap;

end
% return
% get overall slope
% idx = meta.phase == "initial";
% xdata = days(meta.Date(idx) - datetime(2019, 10, 22));
% ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
%
% p = polyfit(xdata, ydata, 1);
% plot(ax, -1:30, polyval(p, -1:30), 'Color', 'k', ...
%     'LineWidth', options.lw_thick);
%
% [rho, p] = corr(xdata, ydata');
% fprintf('All rats correlation = %.4g (P = %.4g)\n', rho, p);
%
%
% % ax.Title.String = "DKL initial time period";
% ax.YLabel.String = top_ylabel;
% ax.XLabel.String = "Initial training [days]";
% ax.XLim = [0 28];
