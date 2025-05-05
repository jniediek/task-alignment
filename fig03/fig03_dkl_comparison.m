% JN 2023-08-29
function fig03_dkl_comparison(fig, position, data, options)


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

ax = axes(fig, 'Position', position);
ax.NextPlot = "add";

use_param = 1;
meta = data.meta;
LL_imax_all_opt = data.LL_imax_all_opt;

rats = 4:8;
electrode_first_4_5 = datetime(2020, 10, 18);
electrode_first_7_8 = datetime(2020, 2, 23);

% get three datasets: initial phase, first 28 days post-implant, and
% last 28 days of life
irats = [1 2 4 5];
plot_data = cell(length(irats), 3);

for i = 1:length(irats)
    irat = irats(i);
    rat = rats(irat);
%     idx = (meta.Rat == rat) & (meta.phase == "initial");
% %     xdata = days(meta.Date(idx) - datetime(2019, 10, 22));
%     ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
%     plot_data{i, 1} = ydata;
%     
%     idx = (meta.Rat == rat) & (meta.phase == "implanted");
    if rat < 6
        first_day = electrode_first_4_5;
    elseif rat == 6
       first_day = nan;
    elseif rat > 6
        first_day = electrode_first_7_8;
    end
    
    idx_first_month = (meta.Date >= first_day) & (meta.Date <= first_day + days(28));
    idx = idx_first_month & (meta.Rat == rat);
    if use_tc
        ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
    else
        ydata = data.betas(LL_imax_all_opt(idx))';
    end
    
%     ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
    plot_data{i, 1} = ydata;
    
    rdays = meta.Date(meta.Rat == rat);
    last_day = rdays(end);
    idx_last_month = (meta.Date >= last_day - days(28));
    idx = idx_last_month & (meta.Rat == rat);
    if use_tc
        ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
    else
        ydata = data.betas(LL_imax_all_opt(idx))';
    end
%     ydata =  data.adkls(use_param, LL_imax_all_opt(idx, use_param));
    plot_data{i, 2} = ydata;
   
end

for i = 1:length(irats)
    irat = irats(i);
    for j = 1:2
        ydata = plot_data{i, j};
        boxchart(ax, 4*(i-1) + j - 1 + zeros(length(ydata), 1), ydata, ...
            'BoxFaceColor', options.RatColors(irat, :), ...
            'MarkerColor', options.RatColors(irat, :), ...
            'BoxFaceAlpha', 2*(j-1)/5 + .2, ...
            'MarkerStyle', '.', ...
            'JitterOutliers', 'on', ...
            'BoxWidth', .95)
    end
    [~, p, ~, stats] = ttest2(plot_data{i, 1}, plot_data{1, 2});
    pstarbar(ax, 4*(i-1), 4*(i-1) + 1, 0.89 * (ymax - ymin) + ymin, p)
    fprintf('DKL comparison implanted. Rat %d P = %.4g\n', irat, p)
    stats
end

for j = 1:2
    lgdo(j) = boxchart(ax, [-8 -8], [4 5], 'BoxFaceColor', options.RatColors(1, :), ...
        'BoxFaceAlpha', 2*(j-1)/5 + .2, ...
        'MarkerStyle', '.', ...
        'JitterOutliers', 'on', 'BoxWidth', .2);
end

ax.XTick = [2 6 10 14] - 1;
ax.XTickLabel = irats;
ax.XLabel.String = "Rat";
ax.YGrid = "on";
ax.YLim = [ymin ymax];
ax.XLim = [-1 15];
ax.YLabel.String = "Task alignment";

lgd = legend(lgdo, 'First month implanted', 'Last month implanted');
lgd.FontSize = 10;
lgd.EdgeColor = 'none';
lgd.Position = [.7 .95 .08 .02];
