function ax = fig06_subject_curves(pos, options)
% JN 2026-08-05
% Panel D of figure 6: log-likelihood over beta for three example subjects.
%
%   AX = FIG06_SUBJECT_CURVES(POS, OPTIONS) splits the normalized position
%   POS = [left bottom width height] into three side-by-side axes and returns
%   them as a 1x3 array. The whole row carries the single panel letter D, so
%   the split happens here rather than in the FIG06 driver.
%
%   Each axes shows the mean log-likelihood of one subject's choice steps as a
%   function of beta, with a dot at the maximum: that argmax is the subject's
%   beta_hat. The three are picked to span the range -- near-deterministic,
%   intermediate, near-uniform -- so the panel shows both that the estimate is
%   well defined and how differently the curve is shaped at the two ends.
%
%   MATLAB version of gg_figures/code/fig06_ll_sixpanel.py, panels D/E/F.
%
%   See also FIT_SUBJECT_BETAS, FIT_BETA_MLE.

% Sizes tuned for a ~1/6-A4 panel split three ways, as in FIG06_BETA_COHORTS.
label_size = 9;
tick_size = 8;

% Near-deterministic, intermediate, near-uniform. The last is the second point
% of the beta grid, i.e. as close to uniform-random as the grid gets.
targets = [2.00 0.35 0.0101];

[fits, betas, logPflat] = fit_subject_betas();

S = load('../data/fig06_steps.mat', 'subject', 'state', 'action');
subject = double(S.subject(:));
state   = double(S.state(:));
action  = double(S.action(:));

beta_hats = [fits.beta_hat];

n = numel(targets);
curves = cell(1, n);
chosen = zeros(1, n);

for i = 1:n
    % MIN returns the first index on ties, and two of the three targets are
    % ties. That resolves them by the order the subjects are stored in, which
    % is the order the Python reference selects in. Do not sort FITS first.
    [~, chosen(i)] = min(abs(beta_hats - targets(i)));

    sel = subject == fits(chosen(i)).subject;
    [~, curves{i}] = fit_beta_mle(state(sel), action(sel), betas, logPflat);
end

for i = 1:n
    fprintf(['Panel D, target beta = %.4f: subject %d, ' ...
             'N = %d steps, beta_hat = %.6f\n'], ...
        targets(i), fits(chosen(i)).subject_id, fits(chosen(i)).n_steps, ...
        fits(chosen(i)).beta_hat);
end

% One y range for all three, so the curves are comparable across the row.
all_ll = cat(2, curves{:});
y_lim = [min(all_ll(:)) max(all_ll(:))];
y_lim = y_lim + [-1 1] * .04 * diff(y_lim);

gap = .04 * pos(3);
w = (pos(3) - (n - 1) * gap) / n;

ax = gobjects(1, n);
for i = 1:n
    sub_pos = [pos(1) + (i - 1) * (w + gap), pos(2), w, pos(4)];
    ax(i) = axes('Position', sub_pos);
    ax(i).NextPlot = "add";

    ll = curves{i};
    beta_hat = fits(chosen(i)).beta_hat;
    [ll_max, i_max] = max(ll);

    % Shaded down to the curve's own minimum rather than to the axis, so the
    % shading measures how much the likelihood varies over the grid.
    fill(ax(i), [betas; betas(end); betas(1)], [ll; min(ll); min(ll)], ...
        options.LabelColor, 'FaceAlpha', .1, 'EdgeColor', 'none');
    plot(ax(i), betas, ll, 'LineWidth', 1.5, 'Color', options.LabelColor);
    plot(ax(i), betas(i_max), ll_max, '.', 'MarkerSize', 10, ...
        'Color', options.LabelColor);

    % The left subject peaks at the right edge of the grid and the right one at
    % the second grid point, so the label has to fall back inside the axes at
    % both ends.
    if betas(i_max) > mean(betas)
        h_align = "right";
    else
        h_align = "left";
    end
    text(ax(i), betas(i_max), ll_max, sprintf(' \\beta = %.2f ', beta_hat), ...
        'Color', options.LabelColor, 'FontSize', tick_size, ...
        'HorizontalAlignment', h_align, 'VerticalAlignment', 'bottom');

    % betas(1) is 1e-6, so starting the axis at 0 moves nothing visibly and
    % lets the grid carry a tick at the left edge.
    ax(i).XLim = [0 betas(end)];
    ax(i).YLim = y_lim;
    ax(i).XTick = 0:1:2;
    ax(i).FontSize = tick_size;
    ax(i).Box = "off";
    ax(i).YGrid = "on";
    ax(i).TickLength = [.03 .03];

    if i == 1
        ax(i).YLabel.String = 'Mean log-likelihood';
        ax(i).YLabel.FontSize = label_size;
    else
        ax(i).YTickLabel = [];
    end
end

% One shared x label under the middle axes, as fig02_a fakes its shared labels.
text(ax(2), .5, -.16, '\beta', 'Units', 'normalized', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'FontSize', label_size);
