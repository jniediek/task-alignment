addpath('../common/')
options = get_options()

S = load('../data/fig_03_data.mat');
data = S.data;

fig = figure("Position", [0 1000 800 700], "Color", 'w');

left = .1;
gap = .1;

a_bottom = .57;
d_bottom = .1;
width = .2;
a_height = .33;

pos_a = [left a_bottom width a_height];
pos_b = [left + width + gap a_bottom width a_height];
pos_c = [left + 2*(width + gap) a_bottom width a_height];

d_height = .85 * a_height;
d_gap = gap * .7;

pos_d1 = [left d_bottom width d_height];
pos_d2 = [left + width + d_gap d_bottom width d_height];
pos_e = [left + 2*(width + d_gap) + d_gap d_bottom width d_height];


height_factor = .45;

pos_a_bot = pos_a;
pos_a_bot(4) = pos_a_bot(4) * height_factor;
pos_a_top = pos_a;
pos_a_top(2) = pos_a_top(2) + .5 * pos_a(4);
pos_a_top(4) = pos_a_top(4) * height_factor;

pos_b_bot = pos_b;
pos_b_bot(4) = pos_b_bot(4) * height_factor;
pos_b_top = pos_b;
pos_b_top(2) = pos_b_top(2) + .5 * pos_b(4);
pos_b_top(4) = pos_b_top(4) * height_factor;

options.target_var = 'beta';

% fig03_a(pos_a, data, options);
% fig03_b(pos_b, data, options);
% fig03_dkl_comparison(pos_c, data, options);

fig04_param_heatmap(pos_a, data);


local_options.ylabel = "Best-fitting poke reward";
local_options.ylim = [0 30];
fig04_param_evolution(pos_b, data, 'poke_rew', local_options, options);
extra_analysis_rewards_long_time(data, 'poke_rew')

local_options.ylabel = "Best-fitting rotation cost";
local_options.ylim = [0 30];
fig04_param_evolution(pos_c, data, 'orien_factor', local_options, options);
extra_analysis_rewards_long_time(data, 'orien_factor')

S = load('../data/bhv_table_computed_states.mat');

fprintf('\n\n----> Starting plot of trajectory comparison\n')
fig04_plot_bhv_comparison(pos_d1, pos_d2, pos_e, S);
set(findall(gcf,'-property','FontSize'),'FontSize', 10)
set(findall(gcf, '-property', 'FontName'), 'FontName', options.FontName)


letters = 'ABCDE';
xs = ones(5, 1) * left - .1;
xs(2) = xs(2) + width + 1.1*gap;
xs(3) = xs(2) + width + 1.2*gap;
xs(5) = xs(4) + 2 * (width + d_gap) + 1.2*d_gap;
% these are C and F
% xs([3 6]) = xs([2 5]) + width + 1.2*gap;
% xs(8) = xs(7) + 2*(width + d_gap) + 1.2*d_gap;
ys = [pos_a(2) pos_a(2) pos_a(2) pos_d1(2) pos_d1(2) pos_d1(2)];
ys = ys + a_height + .02;
for i = 1:length(letters)
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', options.FontSizeLetters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        options.FontName);
end
set(fig.Children, 'FontName', 'Nimbus Sans');

fname = sprintf('fig03_using_%s.png', options.target_var);

print('-dpng', '-r250', fname);
% exportgraphics(fig, fname, 'Resolution', 200);