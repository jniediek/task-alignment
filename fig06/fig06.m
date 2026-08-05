% JN 2026-08-05
% Plotting code for Fig 6
%
% Panels A and F are still placeholders. See the individual fig06_*.m files for
% what each of them will become.

addpath('../common')
options = get_options();

% The four policies panel C draws, marked on panel B's curve in the same
% colours so the two panels can be read together. Indices into the beta grid of
% ../data/fig06_policy.mat, spanning it from the uniform end to the sharpest.
options.pol_nums = [1 51 101 200];

% winter(6) rather than winter(4), as in fig02: taking the first four rows of a
% six-step ramp keeps the colours off the extreme ends.
options.TitleColors = winter(6);

% 800 px is the A4 text width, so a full page would be about 1130 px high.
% Three rows of 300 px leave room for the legend below the figure on the same
% page. Panel E's font sizes are absolute and were tuned at 400 x 370 px, so
% they read slightly larger in the shorter box; that is intended.
figheight = 900;

fig = figure("Position", [0 0 800 figheight], 'Color', 'w');

% Three rows of two panel boxes filling the page. A box is the space a panel
% owns; the axes inside it are inset from the box so each panel keeps its own
% margins for tick labels and axis labels.
box_w = .5;
box_h = 1/3;
col_left = [0 box_w];
row_bottom = [2 * box_h, box_h, 0];

box_a = [col_left(1) row_bottom(1) box_w box_h];
box_b = [col_left(2) row_bottom(1) box_w box_h];
box_c = [col_left(1) row_bottom(2) box_w box_h];
box_d = [col_left(2) row_bottom(2) box_w box_h];
box_e = [col_left(1) row_bottom(3) box_w box_h];
box_f = [col_left(2) row_bottom(3) box_w box_h];

% Insets are [left bottom width height] as fractions of the box. Panel E's is
% the one fig06_beta_cohorts_preview.m was tuned with, at the size a sixth of
% this page has, so panel E renders exactly as it did there.
inset = [.14 .19 .83 .77];
inset_plain = [.1 .1 .8 .8];

pos_a = inset_box(box_a, inset_plain);
pos_b = inset_box(box_b, inset);
pos_c = inset_box(box_c, inset);
pos_d = inset_box(box_d, [.1 .19 .85 .7]);
pos_e = inset_box(box_e, inset);
pos_f = inset_box(box_f, inset);

% The policy this figure is built on has a known flaw. Reported here rather
% than corrected, so it is on the record every time the figure is made.
check_policy_symmetry();

fig06_task_schematic(pos_a, options);
fig06_value_complexity(pos_b, options);
fig06_sample_policies(pos_c, options);
fig06_subject_curves(pos_d, options);

cohorts = compute_cohort_betas();

for k = 1:numel(cohorts)
    fprintf('Cohort >= %d games: N = %d subjects, mean beta_hat = %.4f\n', ...
        cohorts(k).threshold, cohorts(k).n_subjects, mean(cohorts(k).betas));
end

fig06_beta_cohorts(pos_e, cohorts, options);

[~, model_tbl] = fig06_beta_vs_avg_steps(pos_f, [], options);

fprintf('Panel F: model curve %.4f guesses/game at beta = %g, %.4f at beta = %g\n', ...
    model_tbl.mean_steps(1), model_tbl.beta(1), ...
    model_tbl.mean_steps(end), model_tbl.beta(end));

letters = 'ABCDEF';
boxes = [box_a; box_b; box_c; box_d; box_e; box_f];
xs = boxes(:, 1) + .01;
ys = boxes(:, 2) + box_h - .03;

for i = 1:length(letters)
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', options.FontSizeLetters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        options.FontName, "HorizontalAlignment", "left");
end

set(fig.Children, 'FontName', 'Nimbus Sans');
print('-dpng', '-r300', 'fig06.png')


function pos = inset_box(box, inset)
% Place an axes inside a panel box, INSET given as fractions of the box.
pos = [box(1) + inset(1) * box(3), box(2) + inset(2) * box(4), ...
    inset(3) * box(3), inset(4) * box(4)];
end
