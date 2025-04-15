% JN 2025-04-15
% Plotting code for Fig 1


fig = figure("Position", [0 0 800 800], 'Color', 'w');

addpath('../common')
options = get_options();

left_tight = .02;
gap = .15;
a_bottom = .5;

a_width = .41;
a_height = .47;
d_bottom = .06;
e_bottom = .02;
width = .4;
traj_height = .47;
text_height = .4;

pos_a = [left_tight a_bottom a_width a_height];
pos_b = [left_tight + width + gap a_bottom a_width a_height];
pos_traj = [left_tight e_bottom a_width traj_height];
pos_text = [left_tight + width + .1  d_bottom a_width*1.12 text_height];

ax_a = axes("Position", pos_a);
fig01_a(ax_a, options)

ax_b = axes("Position", pos_b);
fig01_b(ax_b, options);

% load example trajectories
example_fname = '../data/example_data_1.mat';

S = load(example_fname);
S.rel_trials = [53 66 23 154];

ax_traj = axes('Position', pos_traj);
ax_text = axes('Position', pos_text);

fig01_trial_trajectory(ax_traj, ax_text, S);

letters = 'ABCD';
xs = ones(6, 1) * left_tight - .02;
xs(2) = xs(2) + width + gap/2;
xs(4) = xs(4) + width + gap/2;

ys = [pos_a(2) pos_a(2) pos_traj(2) pos_traj(2)]; 
ys(1:2) = ys(1:2) + a_height - .02;
ys(3:4) = ys(3:4) + traj_height - .03;


for i = 1:length(letters)
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', options.FontSizeLetters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        options.FontName);
end
set(fig.Children, 'FontName', 'Nimbus Sans');
exportgraphics(fig, 'fig01.png', 'Resolution', 300)