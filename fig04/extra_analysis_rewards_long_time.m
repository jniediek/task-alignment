function extra_analysis_rewards_long_time(data, variable)
rats = 4:8;

meta = data.meta;
rel_var = data.opts.(variable);
best_param = data.best_param;

summary_table = cell(length(rats), 3);
summary_table_implanted = cell(length(rats), 3);

for irat = 1:5
    rat = rats(irat);
    idx = (meta.Rat == rat)  & (meta.phase == "initial");
    rat_opt = best_param(idx);
    rel_data = rel_var(rat_opt);
    xaxis = days(meta.Date(idx) - datetime(2019, 10, 22));
    summary_table{irat, 1} = xaxis;
    summary_table{irat, 2} = rel_data;
    summary_table{irat, 3} = rat + zeros(length(xaxis), 1);
    
    idx = (meta.Rat == rat)  & (meta.phase == "implanted");
    if ~any(idx)
        continue
    end
    rat_opt = best_param(idx);
    best_oc = rel_var(rat_opt);
    temp_days = meta.Date(idx);
    xaxis = days(temp_days - temp_days(1));
    summary_table_implanted{irat, 1} = xaxis;
    summary_table_implanted{irat, 2} = best_oc;
    summary_table_implanted{irat, 3} = rat + zeros(length(xaxis), 1);
end

modes = ["initial", "implanted"];

for i_mode = 1:2
    name = modes(i_mode);
    if i_mode == 1
        t_data = summary_table;
    else
        t_data = summary_table_implanted;
    end
end

for i = 1:3
    tbl(:, i) = vertcat(t_data{:, i});
end

tbl = array2table(tbl, 'VariableNames', {'Day', 'Param', 'Rat'});
mdl = fitlme(tbl, 'Param ~ Day + (Day|Rat)');
disp(mdl);
% coefs = mdl.Coefficients.Estimate;
% line_x = 0:(max(tbl.Day));
% line_y = coefs(1) + coefs(2) * line_x;
% plot(ax1, line_x, line_y, 'k', 'LineWidth', 1.5)
amdl = anova(mdl);
fprintf('\n\n Name: %s\n', name);
fprintf('%s: a effect for %s (estimate, %.4g ± %.4g; t(%d) = %.4g; p = %.4g)\n', ...
    variable, mdl.CoefficientNames{2}, mdl.Coefficients.Estimate(2), ...
    mdl.Coefficients.SE(2), mdl.Coefficients.DF(2), mdl.Coefficients.tStat(2), mdl.Coefficients.pValue(2));
fprintf('%s: a effect for %s (F(%d, %d) = %.3g; p = %.2g)\n', ...
    variable, amdl.Term{2}, ...
    amdl.DF1(2), amdl.DF2(2), amdl.FStat(2), amdl.pValue(2));

