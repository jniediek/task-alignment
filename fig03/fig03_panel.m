function ax = fig03_panel(position, data, tab_bhv, bhvmeasure, phase, options)

ax = axes('Position', position);
ax.NextPlot = "add";

rats = 4:8;

if strcmp(phase, "initial")
    do_initial = true;
    irats = 1:5;
    alpha = 1; % plot rat markers with full opacity
    xlabel = "Initial training [days]";
elseif strcmp(phase, "implanted")
    do_initial = false;
    irats = [1 2 4 5];
    alpha = .3; % plot with smaller opacity.
    xlabel = "Implanted period [days]";
else
    error("Phase has to be initial or implanted")
end

if strcmp(bhvmeasure, "TA")
    ylabel = "Task alignment";
    do_taskalignment = true;
else
    ylabel = "Success rate";
    do_taskalignment = false;
    ylim = [.2 .9];
end


meta = data.meta;

lgddata = zeros(numel(irats), 1);

for irat = irats
    rat = rats(irat);
    idx = (meta.Rat == rat) & (meta.phase == phase);
    dates = meta.Date(idx);
    if do_initial
        first_day = datetime(2019, 10, 22);
    else
        first_day = dates(1);
    end

    % the xaxis are the days since start of the observation phase
    xdata = days(dates - first_day);

    if do_taskalignment
        ydata = data.betas(data.LL_imax_all_opt(idx))';
    else
        ydata = tab_bhv.frac_succ(idx);
    end

    lgddata(irat) = scatter(ax, xdata, ydata, 7, ...
        'Marker', options.RatMarkers(irat), ...
        'MarkerFaceColor', options.RatColors(irat, :), ...
        'MarkerEdgeColor', options.RatColors(irat, :), ...
        'MarkerEdgeAlpha', alpha, ...
        'MarkerFaceAlpha', alpha);
    if ~do_initial
        plot(ax, xdata, movmean(ydata, 28), 'LineStyle', '-', ...
            'Color', options.RatColors(irat, :), 'LineWidth', 2);
        fprintf('Rat %d up to day %d\n', rat, xdata(end));
    end
end

ax.XLabel.String = xlabel;
ax.YGrid = "on";

% insert analysis period markers

% ymin = ylim(1);
% ygap = .04;
% l = ax2.XLim(2);
if do_initial
    ax.XLim = [0 28];
    ax.YLabel.String = ylabel;
else
    starts = [0 50 150];
    for i = 1:3
        f = starts(i);
        xline(ax, f, 'LineWidth', 1.5, 'Color', .1 * [1 1 1]);
    end

    ax.XLim = [0 410];
end

if ~do_taskalignment
    ax.YLim = ylim;
end

ax.YTick = ax.YTick(1:2:end);
% ax.YTick = ax.YTick(1:2:end);
