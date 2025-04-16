% JN 2025-04-16
% Plot Fig 2

addpath('../common');

options = get_options();
options.TitleColors = winter(6);

fig = figure("Position", [0 0 800 700], 'Color', 'w');

left = .08; 
gap = .12;

a_bottom = .6;
c_bottom = .1;

a_width = .45;
b_width = .35;
c_width = .38;
d_width = .3;

height = .35;
a_height = .33;

pos_a = [left a_bottom a_width a_height];
pos_b = [left + a_width + gap a_bottom b_width a_height];
pos_c = [left c_bottom c_width height];
pos_d = [left + a_width + gap c_bottom d_width height];

S = load('../data/fig02_probabilities.mat');
S.pol_nums = [1 110 130 200];
S.action_nums = [2 13 14 19 22 23];
S.action_names = ["A2" "C1" "C2" "D" "AC" "TO"];
S.states_long = ["B2_OUT_2_0_B", "B2_OUT_0_0_B"];
S.select_actions = [[2 23]; [2 22]];
S.select_actions_idx = [[1 6]; [1 5]];

T = load('../data/vi_curve_info.mat');
S.Betas = T.betas;

fig02_a(pos_a, S, options)
fig02_b(pos_b, S, options);

ax_c = axes("Position", pos_c);
fig02_c(ax_c, S, T, options);

ax_d = axes("Position", pos_d);
fig02_d(ax_d, options);

letters = 'ABCD';
xs = ones(6, 1) * left - .08;
xs(2) = xs(1) + a_width + gap;
xs(4) = xs(4) + a_width + gap;
ys = [pos_a(2) pos_a(2) pos_c(2) pos_c(2)];
ys(3:end) = ys(3:end) + height;
ys(1:2) = ys(1:2) + a_height;
ys = ys + .02;


for i = 1:length(letters)
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', options.FontSizeLetters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        options.FontName);
end

set(fig.Children, 'FontName', 'Nimbus Sans');

print('fig_02.png', '-dpng', '-r250');