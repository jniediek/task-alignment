function ax = fig03_b(position, data, options, ylim)

if strcmp(options.target_var, 'TC')
    use_tc = true;
    ymin = 0;
    ymax = 8000;
elseif strcmp(options.target_var, 'beta')
    use_tc = false;
    ymin = 0.05;
    ymax = 0.15;
else
    error('target var has to be TC or beta')
end

ax = axes('Position', position);
ax.NextPlot = "add";

use_param = 1;
meta = data.meta;
LL_imax_all_opt = data.LL_imax_all_opt;


rats = 4:8;
irats = [1 2 4 5];

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
    xline(ax, f, 'LineWidth', 1.5, 'Color', .1 * [1 1 1]);
    text(ax, f, ax.YLim(2), sprintf(' %i ↦', i), 'VerticalAlignment', 'top')
 
end