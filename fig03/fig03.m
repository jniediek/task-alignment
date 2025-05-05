% JN 2025-04-16
% Plot Fig 3

addpath('../common');

options = get_options();

fig = figure("Position", [0 1000 800 600], "Color", 'w');

set(0, 'defaultAxesFontName', options.FontName);
set(0, 'defaultTextFontName', options.FontName);

lw_thick = 1.5;
lw_thin = 1;
options.lw_thick = lw_thick;
options.lw_thin = lw_thin;

S = load('../data/fig_03_data.mat');

data = S.data;
tab_bhv = S.tab_bhv;

left = .08;
a_bottom = .57;
d_bottom = .1;
gap = .1;
small_width = .3;
large_width = .45;
height = .35;

x1 = .02;
x2 = left + small_width + .02;
y_bot = d_bottom + height + .01;
y_top = a_bottom + height + .01;

xs = [x1 x2 x1 x2];
ys = [y_top y_top y_bot y_bot];

pos_beta_ini = [left a_bottom small_width height];
pos_beta_long = [left + small_width + gap a_bottom large_width height];

options.target_var = 'beta';
options.plot_xlabel = false;

ylim_a = [0.06 0.11];
ax_a = fig03_a(pos_beta_ini, data, options, ylim_a);
ylim_b = [0.06 .15];
ax_b = fig03_b(pos_beta_long, data, options, ylim_b);

ax_b.YTick = 0.01 + (ylim_b(1):0.02:ylim_b(2));

arrow_x = [ax_a.Position(1) + ax_a.Position(3) + .005, ax_b.Position(1) - 0.005];
yypos = ax_b.Position(2) + diff(ylim_a)/diff(ylim_b) * ax_b.Position(4);
arrow_y = [ax_a.Position(2) + ax_a.Position(4), yypos];

annotation(fig, 'line', arrow_x, arrow_y, 'Color', .2 * [1 1 1])

arrow_y = ax_a.Position(2) * [1 1];
annotation(fig, 'line', arrow_x, arrow_y, 'Color', .2 * [1 1 1])

pos_success_ini = pos_beta_ini;
pos_success_long = pos_beta_long;

pos_success_ini(2) = d_bottom;
pos_success_long(2) = d_bottom;

ylim = [.2 .9];
plot_learning_helper(data, tab_bhv, pos_success_ini, pos_success_long, ...
    options, ylim)


letters = 'ACBD';
for i = 1:length(letters)
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', options.FontSizeLetters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        options.FontName, "HorizontalAlignment", "left");
end


set(fig.Children, 'FontName', 'Nimbus Sans');

fname = 'fig_03.png';
print('-dpng', '-r300', fname)


pos_beta_comp = [.12 .12 .8 .7];
supp_fig = figure("Position", [0 0 500 400], 'Color', 'w');

fig03_dkl_comparison(supp_fig, pos_beta_comp, data, options);
set(supp_fig.Children, 'FontName', 'Nimbus Sans');
fname = 'supp_fig_learning_boxplot.png';
print('-dpng', '-r300', fname);