function fig04_param_heatmap(position, data)
% JN 2023-08-29
ax = axes('Position', position);

ises = 270;
meta = data.meta;
opts = data.opts;

pk = unique(opts.poke_rew);
n_pk = length(pk);
oc = unique(opts.orien_factor);
n_oc = length(oc);

LL_max_all_opt = data.LL_max_all_opt;

ar = reshape(LL_max_all_opt(ises, :)/meta.NCleaned(ises), n_oc, n_pk);

imagesc(ar);
colormap('Winter');
cax = colorbar();
xtickidx = [1 3  6 8 10];
ytickidx = [1 3 5 7 9 11 13 15];
% ytick = [0 2 4 6 8 10 20 30];
ax.XTick = xtickidx;
ax.YTick = ytickidx;
ax.XTickLabel = pk(xtickidx);
ax.YTickLabel = oc(ytickidx);
ax.Title.String = "L.L. per action";
ax.Title.FontWeight = 'normal';
ax.YLabel.String = 'Rotation cost';
ax.XLabel.String = 'Poke reward';
clim([-.66 -.62])
ax.YDir = 'normal';
% mark the max
ax.NextPlot = "add";
[mm, imm] = max(ar(:));
[xi, yi] = ind2sub([n_oc, n_pk], imm);
plot(yi, xi, 'kx')
% ar(xi, yi)
% mm