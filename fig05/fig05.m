addpath('../common/')

options = get_options();
options.ColorBeta = [0 0 .7];
options.ColorFiringRate = [.7 0 .1];


% JN 2024-07-17 switching to smaller figure
% figheight = 1200;
figheight = 800;

fig = figure("Position", [0 0 800 figheight], 'Color', 'w');

left = .08;
gap = .13;
% a_bottom = .68;
% c_bottom = .3;
width = .36;
% a_height = .25;
a_bottom = .6;
c_bottom = .1;
a_height = .3;
c_height= .35;

% e_bottom = .05;
% e_height = .12;

pos_a = [left a_bottom width a_height];
pos_b1 = [left + width + gap c_bottom + a_height*2 width a_height*.75];
pos_c = [left c_bottom width c_height];
pos_b2 = [left + width + gap c_bottom + a_height width a_height*.75];
pos_d = [left + width + gap c_bottom width a_height/2];
% pos_e = [left e_bottom width e_height];
% pos_f = [left + width + gap e_bottom width e_height];

fname = '../data/all_correlations_computed.mat';
beta_struct = load(fname);

fig05_plot_betas(pos_a, beta_struct, options);

S = load('../data/correlation_table.mat');

info = S.corr_table(end-8, :);
options.plot_label = false;
fig05_plot_example(pos_b1, info, beta_struct, options)
% info = S.corr_table(end-11, :);
info = S.corr_table(3, :);
options.plot_label = true;
fig05_plot_example(pos_b2, info, beta_struct, options)
%%
fig05_plot_correlations(pos_c, beta_struct, options);

fname = fullfile('..', 'data', 'roc_data_computed_beta.mat');
S = load(fname);
all_rocs = S.all_rocs;
options.mode = "panel";
options.do_plot = true;
fprintf('ROC for beta\n');
fig05_plot_roc(pos_d, all_rocs, options)

% fig04_plot_reward_histograms(pos_e, beta_struct, options);

fname = fullfile('..', 'data', 'roc_data_computed_reward.mat');
S = load(fname);
all_rocs = S.all_rocs;
options.do_plot = false;
fprintf('ROC for rewards\n');
fig05_plot_roc(pos_d, all_rocs, options)

% figure();
% fig04_plot_reward_beta(pos_f, options)



letters = 'ABCD';
xs = ones(6, 1) * left - .07;
xs([2 4 6]) = xs([2 4 6]) + width + gap;
ys = [pos_a(2) pos_a(2) pos_c(2) pos_c(2)]; % pos_e(2) pos_e(2)];
ys(1:2) = ys(1:2) + a_height + .03;
ys(3) = ys(3) + c_height + .03;
ys(4) = ys(4) + a_height/2 + .03;
% ys(5) = ys(5) + e_height + .03;
% ys(6) = ys(6) + e_height + .03;

for i = 1:length(letters)
    
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', options.FontSizeLetters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        options.FontName);
end
set(fig.Children, 'FontName', 'Nimbus Sans');
print('-dpng', '-r250', 'fig05.png')