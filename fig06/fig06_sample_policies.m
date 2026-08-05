function ax = fig06_sample_policies(pos, options)
% JN 2026-08-05
% Panel C of figure 6: sample policies from the softmax policy family.
%
%   AX = FIG06_SAMPLE_POLICIES(POS, OPTIONS) splits the normalized position
%   POS = [left bottom width height] into two stacked axes, one per state, and
%   returns them as a 1x2 array.
%
%   Each axes shows pi_beta(a|s), the probability of guessing the a-th smallest
%   still-possible number, for the four betas in OPTIONS.POL_NUMS, coloured with
%   OPTIONS.TITLECOLORS. Panel B marks the same four betas in the same colours.
%
%   As beta grows the policy goes from uniform over the s legal guesses towards
%   the best action. The two states show that the same beta concentrates weakly
%   over a wide interval and strongly over a narrow one: at s = 100 the peak
%   only rises from 0.010 to 0.031, at s = 20 from 0.050 to 0.169.
%
%   The dashed line marks the best action. It is deliberately not at the
%   midpoint of the interval: the optimal policy cuts slightly above the middle
%   (53 of 100, 11 of 20), so binary search is not quite what it converges to.
%
%   Data: ../data/fig06_policy.mat, with betas (200x1, linspace(1e-6, 2, 200))
%   and Policy (200x101x101), where Policy(k, s+1, a) = pi_betas(k)(a | s). The
%   s+1 offset exists because state 0 ("just solved") occupies row 1; that row
%   is all zeros and is never a choice step. Entries with a > s are exactly 0.

% Sizes tuned for a ~1/6-A4 panel, as in FIG06_BETA_COHORTS.
label_size = 9;
tick_size = 8;

states = [100 20];
y_lims = [0 .035; 0 .18];

S = load('../data/fig06_policy.mat', 'betas', 'Policy');

n = numel(states);
inner_h = pos(4) * .8 / n;
hgap = pos(4) * .2 / (n - 1);

ax = gobjects(1, n);

for i_st = 1:n
    s = states(i_st);

    ax(i_st) = axes('Position', [pos(1), pos(2) + (n - i_st) * (inner_h + hgap), ...
        pos(3), inner_h]);
    ax(i_st).NextPlot = "add";

    % The best action is read at the largest beta, where the policy is sharpest.
    % It must not be taken per curve: for 36 of the 100 states the argmax shifts
    % by one somewhere along the grid, and s = 100 is one of them, so a per-beta
    % marker would jump.
    [peak, a_star] = max(squeeze(S.Policy(end, s + 1, 1:s)));

    xline(ax(i_st), a_star, '--', 'Color', .5 * [1 1 1], 'LineWidth', .5);

    fprintf('Panel C, state %3d: best action %d of %d, peak probability %.4f\n', ...
        s, a_star, s, peak);

    for i = 1:numel(options.pol_nums)
        k = options.pol_nums(i);
        probs = squeeze(S.Policy(k, s + 1, 1:s));

        plot(ax(i_st), 1:s, probs, 'LineWidth', 1.5, ...
            'Color', options.TitleColors(i, :));

        % Colour-coded labels rather than a legend box, as fig02_b labels its
        % curves directly, and only on the top row, as fig02_a titles only its
        % top row. They are stacked in the upper left, which every curve leaves
        % empty: labels placed at the peaks would be crossed by the flanks of
        % the sharper curves, since all four peak at the same guess rank.
        if i_st == 1
            % betas(1) is 1e-6, the grid's uniform-random boundary rather than
            % exactly 0, and prints here as 0.00.
            text(ax(i_st), .03, .96 - (numel(options.pol_nums) - i) * .13, ...
                sprintf('\\beta = %.2f', S.betas(k)), 'Units', 'normalized', ...
                'Color', options.TitleColors(i, :), 'FontSize', tick_size, ...
                'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
        end
    end

    if i_st == 1
        text(ax(i_st), a_star - .02 * s, y_lims(i_st, 2), 'best action', ...
            'FontSize', tick_size, 'Color', .4 * [1 1 1], ...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
    end

    text(ax(i_st), .99, .95, sprintf('s = %d', s), 'Units', 'normalized', ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
        'FontSize', tick_size);

    ax(i_st).XLim = [1 s];
    ax(i_st).YLim = y_lims(i_st, :);
    ax(i_st).FontSize = tick_size;
    ax(i_st).Box = "off";
    ax(i_st).YGrid = "on";
    ax(i_st).TickLength = [.015 .015];
end

ax(n).XLabel.String = 'Guess rank';
ax(n).XLabel.FontSize = label_size;

% One shared y label across both rows, as fig02_a and fig02_b fake theirs.
text(ax(n), -.13, 1.1, 'Action probability', 'Rotation', 90, ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', label_size);
