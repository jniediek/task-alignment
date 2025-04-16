function fig02_c(ax, data, vi_data, options)
% JN 2024-08-22 added vi_data;
rel_pos = data.pol_nums;

% dkls = data.dkl_res.DKL;
betas = data.Betas;
state_used = 1;
tab = vi_data.res_by_state{state_used};
x_info = tab.M_info(1:200);
y_value = -tab.M_basic(1:200);
% curve = mean(data.values, 2);

ax.NextPlot = "add";
plot(x_info, y_value, 'LineWidth', 1.5)
ax.XLabel.String = 'I(\pi)';
ax.YLabel.String = 'Value';


fill(ax, [x_info' x_info(end) x_info(1)], [y_value' -200, -200], 'y', ...
    'FaceAlpha', .5, 'EdgeColor', ax.ColorOrder(1, :))

ixs = [145 165];
xshifts = [-1 1];
yshifts = [-.4 .4];


for iar = 1:2
    
    ar = annotation("arrow");
    ar.Parent = ax;
    ar.Position = [x_info(ixs(iar)) y_value(ixs(iar)) xshifts(iar) yshifts(iar)];
    ar.Color = "k";
    % ar.HeadStyle = "cback1";
    ar.HeadWidth = 20;
end
plot(ax, x_info([ixs(1) ixs(2)]), y_value([ixs(1) ixs(2)]), 'LineWidth', 3, 'Color', 'k')
text(ax, x_info(150), 1050, "\beta", "FontSize", 14)
ax.Box = "off";

count = 0;
for ixs = rel_pos
    count = count + 1;
    plot(ax, x_info(ixs), y_value(ixs), '.', 'markersize', 30, 'LineWidth', 3, 'Color', options.TitleColors(count, :))
    str = sprintf("%.3f", betas(ixs));
    text(ax, x_info(ixs) + 10 , y_value(ixs) + 45, ...
        strcat("\beta = ", str), 'Color', options.TitleColors(count, :), 'FontSize', 12)
%     plot(ax, [dkls(ixs) dkls(ixs)], [-100 curve(ixs)], 'k', 'LineWidth', 1)
end

ax.YLim = [y_value(1) y_value(end) * 1.2];
ax.XLim = [-20, ax.XLim(end)];