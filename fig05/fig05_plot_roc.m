% JN 2023-09-19
function fig05_plot_roc(pos, all_rocs, options)

% mode = "isolated";
mode = options.mode;
do_plot = options.do_plot;

if mode == "isolated"
    pos = [.1 .1 .8 .8];
    figure('Color', 'w', 'Position', [0 0 700 700]);
    fname = fullfile('..', 'data', 'roc_data_computed.mat');
    S = load(fname);
    all_rocs = S.all_rocs;
end


det_fa = squeeze(all_rocs(1, :, :));

% calculate the std from the rest
std_det_fa = squeeze(std(all_rocs(2:end, :, :), 1));
% mean_det_fa = squeeze(mean(all_rocs(2:end, :, :), 1));

% errorbar(mean_det_fa(:, 2), mean_det_fa(:, 1), std_det_fa(:, 1), std_det_fa(:, 1), ...
%      std_det_fa(:, 2), std_det_fa(:,2 ));

% use the std but around the mean of the true data
xdata = det_fa(:, 2);
ymean = det_fa(:, 1);
ylow = ymean - std_det_fa(:, 1);
yhigh = ymean + std_det_fa(:, 1);




n_rep = size(all_rocs, 1) - 1;
all_auc = zeros(n_rep+1, 1);

for i_rep = 1:(n_rep+1)
    [sorted_x, idx] = sort(all_rocs(i_rep, :, 2), 2);
    sorted_x = squeeze(sorted_x);
    sorted_y = squeeze(all_rocs(i_rep, idx, 1));
    all_auc(i_rep) = trapz(sorted_x, sorted_y);
end
[~, p, ci, stat] = ttest(all_auc(2:end), .5);
fprintf('AUC: real val = %.4g, df=%d T=%.4g P ttest = %.4g\n', all_auc(1), size(all_auc(2:end), 1) - 1, stat.tstat, p);


if do_plot
    ax = axes('Position', pos);
    
    ax.NextPlot = "add";
    fill([xdata' fliplr(xdata')], [ylow' fliplr(yhigh')], ...
        [0 0 1], 'FaceAlpha', .2, 'EdgeColor', 'none')
    
    
    plot(ax, det_fa(:, 2), det_fa(:, 1), 'Linestyle', '-', ...
        'LineWidth', 1, 'Color', 'k', 'Marker', '.');
    
    plot([0 1], [0 1], 'k-');
    ax.XLabel.String = "False alarm rate";
    ax.YLabel.String = "Detection rate";
    ax.XLim = [0 1];
    ax.YLim = [0 1];
    
    
    text(ax, .98, .1, sprintf('AUC = %.4g', all_auc(1)), ...
        'Units', 'normalized', 'HorizontalAlignment', 'right')
    % keyboard
    if mode == "isolated"
        print('-dpng', '-r200', 'ROC.png');
        figure;
        ax = subplot(1, 1, 1);
        histogram(ax, all_auc(2:end), 30, 'EdgeColor', 'none');
        xline(ax, all_auc(1));
        print('-dpng', '-r200', 'histogram_AUC.png');
    end
    
end
