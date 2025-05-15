function fig04_plot_betas(pos, beta_struct, options)
% JN 2023-09-18

ax1 = axes('Position', pos);
ax1.NextPlot = "add";
rats = [4 5 7 8];
for irat = 1:4
    rat = rats(irat);
    idx = beta_struct.meta.Rat == rat;
    beta_idx = beta_struct.all_betas(:, idx);
    % now we have a problem with nan
    not_nan_idx = ~isnan(beta_idx);
    beta_timecourse = nan(size(beta_idx));
    beta_timecourse(not_nan_idx) = beta_struct.policy_info.Beta(beta_idx(not_nan_idx));
    % plot(beta_timcourse, 'LineWidth', .2, 'Color', .8 * [1 1 1]);
    meandata = mean(beta_timecourse, 2, 'omitnan');
    stddata =  std(beta_timecourse, [], 2, 'omitnan');
    lower = meandata - stddata;
    upper = meandata + stddata;
%     errorbar(1:50, meandata, stddata, 'Color', options.RatColors(irat, :))
    lgdp(irat) = plot(1:50, meandata, 'LineWidth', 2, 'Color', options.RatColors(irat, :));
    fill([1:50 fliplr(1:50)], [lower' fliplr(upper')], ...
        options.RatColors(irat, :), 'FaceAlpha', .1, 'EdgeColor', 'none')
   
end

ax1.XLabel.String = 'Time [min]';
ax1.YLabel.String = 'Best fitting \beta';
ax1.YGrid = "on";

lgd = legend(lgdp, {'Rat 1', 'Rat 2', 'Rat 4', 'Rat 5'});
lgd.Position = [.15 .93 .1 .05];
lgd.EdgeColor = 'none';
lgd.NumColumns = 2;
lgd.Color = 'none';