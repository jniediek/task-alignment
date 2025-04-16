function fig02_d(ax, options)
S = load('../data/fig02_LL_data.mat');
betas = S.betas;
data = S.data;

[md, id] = max(data, [], 2);

ax.NextPlot = "add";
ax.ColorOrder = options.RatColors;
lobj = plot(betas, data, 'LineWidth', 1.5);
plot(betas(id), md, 'kx');

for k = 1:2
    plot([1 1] * betas(id(k)), [-3 md(k)], 'k')
end

ax.YLim = [-.75 -.65];
lgd = legend(lobj, {'Rat 1', 'Rat 2'});
lgd.EdgeColor = options.LegendEdgeColor;
ax.XLabel.String = "\beta";
ax.YLabel.String = "Log likelihood (normalized)";
ax.XLim = [betas(20) betas(130)];