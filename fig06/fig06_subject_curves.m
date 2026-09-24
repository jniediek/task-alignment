function ax = fig06_subject_curves(pos, options)
% JN 2026-08-05
% Panel D of figure 6: log-likelihood over beta for three example subjects.
%
%   Each curve is the mean log-likelihood of one subject's choice steps as a
%   function of beta, with a dot at the maximum: that argmax is the subject's
%   beta_hat. 

label_size = 9;
tick_size = 8;

targets = [2.00 0.35 0.0101];

[fits, betas, logPflat] = fit_subject_betas();

S = load('../data/fig06_steps.mat', 'subject', 'state', 'action');
subject = double(S.subject(:));
state   = double(S.state(:));
action  = double(S.action(:));

P = load('../data/fig06_policy.mat', 'betas');
pol_betas = P.betas(options.pol_nums);
pol_colors = options.TitleColors(1:numel(options.pol_nums), :);

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

all_ll = cat(2, curves{:});
y_lim = [min(all_ll(:)) max(all_ll(:))];
% More room at the bottom, for the label under the lowest curve's end.
y_lim = y_lim + [-.08 .04] * diff(y_lim);

ax = axes('Position', pos);
ax.NextPlot = "add";

% Padded past both ends of the grid, so the drop lines at the edge maxima do
% not fall on the axes.
ax.XLim = [-.1, betas(end)+.1];
ax.YLim = y_lim;
ax.FontSize = tick_size;
ax.Box = "off";
ax.YGrid = "on";
ax.TickLength = [.015 .015];
ax.XLabel.String = '\beta';
ax.XLabel.FontSize = label_size;
ax.YLabel.String = 'Mean log-likelihood';
ax.YLabel.FontSize = label_size;

for i = 1:n
    ll = curves{i};
    beta_hat = fits(chosen(i)).beta_hat;
    [ll_max, i_max] = max(ll);
    col = interp1(pol_betas(:), pol_colors, ...
        min(max(beta_hat, pol_betas(1)), pol_betas(end)));

    % Drop line from the maximum to the beta axis, as in FIG02_D, drawn first
    % so the curves and dots sit on top of it.
    plot(ax, [1 1] * betas(i_max), [y_lim(1) ll_max], 'Color', col, ...
        'LineWidth', .75);
    plot(ax, betas, ll, 'LineWidth', 1.5, 'Color', col);
    plot(ax, betas(i_max), ll_max, '.', 'MarkerSize', 14, 'Color', col);

    if ll(end) >= ll(1)
        v_align = "bottom";
    else
        v_align = "top";
    end
    text(ax, betas(end), ll(end), sprintf('\\beta = %.2f  ', beta_hat), ...
        'Color', col, 'FontSize', tick_size, ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', v_align);
end
