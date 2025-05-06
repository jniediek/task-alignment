% JN 2023-08-28
function fig04_param_evolution(position, data, variable, local_options, options)
fprintf('\nAnalysis for %s\n', variable);
width_a1 = .5;
width_sep = .05;
width_a2 = 1 - width_a1 - width_sep;
pos1 = [position(1) position(2) position(3)*width_a1 position(4)];
pos2 = [position(1) + (width_a1 + width_sep) * position(3) position(2) ...
    position(3) * width_a2 position(4)];

ax1 = axes('Position', pos1);
ax2 = axes('Position', pos2);

ax1.NextPlot = "add";
ax2.NextPlot = "add";

r2data = cell(5, 1);
rats = 4:8;

meta = data.meta;
rel_var = data.opts.(variable);
best_param = data.best_param;

summary_table = cell(length(rats), 3);

for irat = 1:5
    rat = rats(irat);
    idx = (meta.Rat == rat)  & (meta.phase == "initial");
    rat_opt = best_param(idx);
    rel_data = rel_var(rat_opt);
    xaxis = days(meta.Date(idx) - datetime(2019, 10, 22));
    summary_table{irat, 1} = xaxis;
    summary_table{irat, 2} = rel_data;
    summary_table{irat, 3} = rat + zeros(length(xaxis), 1);
    plot(ax1, xaxis, rel_data, 'MarkerFaceColor', ...
        options.RatColors(irat, :), ...
        'MarkerEdgeColor', options.RatColors(irat, :), ...
        'MarkerSize', 4, 'LineStyle', 'none', ...
        'Marker', options.RatMarkers(irat))
    
    % get the mean in the second half
    % second half begins on 3rd November
%     subidx = idx & (meta.Date >= datetime(2019, 11, 3));
%     rat_opt_sub = best_param(subidx);
%     rel_data = rel_var(rat_opt_sub);
%     xaxis = days(meta.Date(subidx) - datetime(2019, 10, 22));
    
%     plot(ax1, xaxis([1 end]), mean(rel_data, 'omitnan') * [1 1], ...
%         'Color', options.RatColors(irat, :), ...
%         'LineWidth', 1.5);
    
    % JN 2024-12-09 add regression line for each rat
    [P, S] = polyfit(xaxis, rel_data, 1);
    ratline = polyval(P, [0 28]);
    plot(ax1, [0 28], ratline, 'Color', options.RatColors(irat, :), ...
        'LineWidth', 2)

    idx = (meta.Rat == rat)  & (meta.phase == "implanted");
    rat_opt = best_param(idx);
    best_oc = rel_var(rat_opt);
    r2data{irat} = best_oc;
end

for i = 1:3
    tbl(:, i) = vertcat(summary_table{:, i});
end
tbl = array2table(tbl, 'VariableNames', {'Day', 'Param', 'Rat'});
mdl = fitlme(tbl, 'Param ~ Day + (Day|Rat)');
disp(mdl);
coefs = mdl.Coefficients.Estimate;
line_x = 0:(max(tbl.Day));
line_y = coefs(1) + coefs(2) * line_x;
plot(ax1, line_x, line_y, 'k', 'LineWidth', 1.5)
amdl = anova(mdl);
fprintf('%s: a significant effect for %s (estimate, %.4g ± %.4g; t(%d) = %.4g; p = %.4g)\n', ...
    variable, mdl.CoefficientNames{2}, mdl.Coefficients.Estimate(2), ...
    mdl.Coefficients.SE(2), mdl.Coefficients.DF(2), mdl.Coefficients.tStat(2), mdl.Coefficients.pValue(2));
fprintf('%s: a significant effect for %s (F(%d, %d) = %.3g; p = %.2g)\n', ...
    variable, amdl.Term{2}, ...
    amdl.DF1(2), amdl.DF2(2), amdl.FStat(2), amdl.pValue(2));

% keyboard

irats = [1 2  4 5];

for i = 1:length(irats)
    irat = irats(i);
    ydata = r2data{irat};
    bar(i, mean(ydata), 'FaceColor', options.RatColors(irat, :), 'EdgeColor', 'none', 'BarWidth', .8);
    errorbar(i, mean(ydata), std(ydata), 'k', 'CapSize', 0, 'LineWidth', 1.5);
%     boxchart(ax2, i + zeros(length(ydata), 1), ydata, ...
%         'BoxFaceColor', options.RatColors(irat, :), 'BoxFaceAlpha', 1, ...
%         'MarkerStyle', '.', ...
%         'JitterOutliers', 'on', ...
%         'MarkerColor', options.RatColors(irat, :), ...
%         'BoxWidth', .8);
    % run a t-test to check value against last fit value
    idx = tbl.Rat == rats(irat);
    vals = tbl.Param(idx);
    val = vals(end);
    % plot(i, val, 'Marker', 'o', 'MarkerFaceColor', options.RatColors(irat, :), 'MarkerEdgeColor', 'none', 'MarkerSize', 6);
    % plot([-.5 .5] + i, [val val], 'Color', 'k', 'LineWidth', 2);
    [h, p, ci, stats] = ttest(ydata, val);
    fprintf('Ttest for rat %d, last value against long-term average, T(%d)=%.4g, P=%.4g\n', ...
        rats(irat), stats.df, stats.tstat, p);
    fprintf('Numerical comparison: last value: %.3g, long-term average: %.3g, difference: %.3g\n', ...
        val, mean(ydata), val - mean(ydata));
end

ax1.XLabel.String = "Days";
ax1.YLabel.String = local_options.ylabel; 

ax2.XLabel.String = "Rat";
ax2.XTick = 1:length(irats);
ax2.XTickLabel = irats;

ax1.YLim = local_options.ylim; 
ax2.YLim = local_options.ylim;

ax2.YAxis.Visible = "off";

ax1.YGrid = "on";
ax2.YGrid = "on";

ax1.Title.String = "First month";
ax2.Title.String = ["Long-term" "average"];
ax1.TitleHorizontalAlignment = "left";
ax2.TitleHorizontalAlignment = "left";