% JN 2023-08-28
function ax = fig03_a(position, data, options, ylim)

if strcmp(options.target_var, 'TC')
    use_tc = true;
    top_ylabel = "D_{KL}(rat estim.; default)";
elseif strcmp(options.target_var, 'beta')
    use_tc = false;
    top_ylabel = "Task alignment";
else
    error('target var has to be TC or beta')
end
% bot_ylabel = "Reward rate [min^{-1}]";

ax = axes('Position', position);
ax.NextPlot = "add";

use_param = 1;
meta = data.meta;
LL_imax_all_opt = data.LL_imax_all_opt;

rats = 4:8;

lmedata = cell(5, 1);

for irat = 1:5
    rat = rats(irat);
    idx = (meta.Rat == rat) & (meta.phase == "initial");
    xdata = days(meta.Date(idx) - datetime(2019, 10, 22));
    if use_tc
        ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
    else
        ydata = data.betas(LL_imax_all_opt(idx))';
    end
    lgddata(irat) = plot(ax, xdata, ydata, 'Marker', options.RatMarkers(irat), ...
        'MarkerFaceColor', options.RatColors(irat, :), ...
        'MarkerEdgeColor', options.RatColors(irat, :), ...
        'MarkerSize', options.RatMarkerSize, ...
        'LineStyle', 'none');
    [rho, p] = corr(xdata, ydata');
    fprintf('Fig. 3A %s irat %d rho = %.4g p = %.4g\n', ...
        options.target_var, irat, rho, p);
    ratvec = rat + zeros(length(xdata), 1);
    lmedata{irat} = [xdata, ydata', ratvec];
end

% get overall slope
idx = meta.phase == "initial";
xdata = days(meta.Date(idx) - datetime(2019, 10, 22));

if use_tc
    ydata = data.adkls(use_param, LL_imax_all_opt(idx, use_param));
else
    ydata = data.betas(LL_imax_all_opt(idx))';
end


p = polyfit(xdata, ydata, 1);
% plot(ax, -1:30, polyval(p, -1:30), 'Color', 'k', ...
%     'LineWidth', options.lw_thick);

[rho, p] = corr(xdata, ydata');
fprintf('Fig. 3A. %s All rats correlation = %.4g (P = %.4g)\n', ...
    options.target_var, rho, p);

% also do the lme here
lmetab = vertcat(lmedata{:});
lmetab = array2table(lmetab, 'VariableNames', {'Day', 'Target', 'Rat'});
lmetab.Rat = categorical(lmetab.Rat);

formula =  'Target ~ Day + (Day|Rat)';
mdl = fitlme(lmetab, formula);
[pval, F, df1, df2] = coefTest(mdl);
fprintf('Using formula %s with target %s\n', formula, options.target_var);
fprintf('Fig 3A coeftest: P = %.3g, F = %.3g, df1 = %d, df2 = %d\n', ...
    pval, F, df1, df2); 


ax.YLabel.String = top_ylabel;
if options.plot_xlabel
    ax.XLabel.String = "Initial training [days]";
end
ax.XLim = [0 28];
ax.YGrid = "on";

lgd = legend(lgddata, {'Rat 1', 'Rat 2', 'Rat 3', 'Rat 4', 'Rat 5'});
pos = lgd.Position;
lgd.Position(2) = pos(2) + .06;
lgd.Position(1) = pos(1) - .17;
% lgd.Color = 'none';
lgd.EdgeColor = options.LegendEdgeColor;

ax.YLim = ylim;
