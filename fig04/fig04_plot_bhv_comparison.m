% JN 2024-01-18
% JN 2024-08-28 also produce tables with the relevant information so that
% the paper will be more concise

function fig04_plot_bhv_comparison(pos1, pos2, pos3, data)

    
% colors = [[0, 0, 1]; [0, .4, 0]; [0, .6, .4]; [.5 .5 .1]; [.8 .8 .1]];
% colors = ["#699d82", "#4e5de8", "#678dcf", "#85479e", "#623391"];
% edgecolors = ["k" "none" "none" "none" "none"];
colors = ["#ffffff", "#c7c7c7", "#c7c7c7", "#333333", "#333333"];
% 
if nargin == 0
    figure('Position', [0 0 1200 400], 'Color', 'w')
    pos1 = [.1 .1 .2 .7];
    pos2 = [.4 .1 .2 .7];
    pos3 = [.7 .1 .2 .7];
    S = load('../data/bhv_table_computed_states.mat');
    data = S;
end

ax1 = axes('Position', pos1);
ax1.NextPlot = "add";
ax2 = axes('Position', pos2);
ax2.NextPlot = "add";
ax3 = axes('Position', pos3);
ax3.NextPlot = "add";

names = ["observed" "all_param" "one_param" "simu_high_beta" "simu_uniform"];

ccols = ["actions_per_trial", "frac_succ"];

my_ax = [ax1 ax2 ax3];
tab_all = data.tab_all;

locs = [1 2.5 3.5 5 6];

sim_stat = cell(2, 1);

for ptype = 1:2
    res_overv = zeros(length(names), 6);
    ccol = ccols(ptype);
    fprintf('-> %s\n', ccol);
    ax = my_ax(ptype);
    ax.YGrid = "on";
    for i = 1:length(names)
        idx = tab_all.dtype == names(i);
        t_data = tab_all.(ccol)(idx);
        if strcmp(ccol , "frac_succ")
            t_data = t_data * 100;
        end
        b_mean = mean(t_data);
        
        b_sem = std(t_data)/sqrt(length(t_data));
        
        bar(ax, locs(i), b_mean, 'EdgeColor', 'k', 'LineWidth', 1, ...
            'FaceColor', colors(i), 'FaceAlpha', 1);
        
        errorbar(ax, locs(i), b_mean, b_sem, 'Marker', '.', ...
            'CapSize', 0, 'LineWidth', 1.5, 'Color', 'k')
        
        fprintf("Group N = %d sessions, M = %.0f trials, %s mean: %.4g sem: %.3g; range %.2f to %.2f\n", ...
            numel(t_data), sum(tab_all.n_trials(idx)), names(i), b_mean, b_sem, ...
            min(t_data), max(t_data));
        res_overv(i, :) = [numel(t_data) sum(tab_all.n_trials(idx)) b_mean b_sem min(t_data) max(t_data)];
    end
    tab_sim = array2table(res_overv, 'VariableNames', ...
        {'NSesssions', 'NTrials', 'Mean', 'SEM', 'Min', 'Max'});
    tab_sim.Name = names';
    tab_sim.Type = repmat(ccol, length(names), 1);
    sim_stat{ptype} = tab_sim;
    ax.XLim = [.4 6.6];
end
% keyboard
% print basic statistics to csv file
% the n_trial can be non-integer numbers because they are already summaries
% of other information. See the script `enrich_and_summarize_simulations.m`
% for that

writetable(vertcat(sim_stat{:}), 'simulation_stats.csv')

tab_dkl = data.tab_dkl;
t_data = table2array(tab_dkl);


start = .6;
stop = 3.3;
width = .1;

for icol = 1:4
    
    dset = t_data(:, icol);
    b_mean = mean(dset);
    b_sem = std(dset)/sqrt(length(dset));
    fprintf("Group %s mean: %.3g sem: %.3g\n", names(icol + 1), b_mean, b_sem);
    
    % at this point, introduce a "break" in plotting, to make the data more
    % readable
    % the main idea of the graphical break is copied from: 
    % https://de.mathworks.com/matlabcentral/fileexchange/3683-breakxaxis
    
    b_mean(b_mean > stop) = b_mean(b_mean > stop) - (stop - start - width);
    
    bar(ax3, icol, b_mean, 'EdgeColor', 'k', 'LineWidth', 1, ...
        'FaceColor', colors(icol + 1), 'FaceAlpha', 1);
    errorbar(ax3, icol, b_mean, b_sem, 'Marker', '.', ...
        'CapSize', 0, 'LineWidth', 1.5, 'Color', 'k')

    
end
% xtick=get(gca,'XTick');
t1 = text(.5, start + width/2 ,'//','fontsize', 10, 'Rotation', 270, 'BackgroundColor', 'w');

ax3.XLim
ax3.YGrid = "on";

ticklabels = ["Observed" "Augmented" "Base" "High \beta" "Uniform"];
for i = 1:2
    my_ax(i).XTick = locs;
    my_ax(i).XTickLabels = ticklabels;
end

ax3.XTick = 1:4;
ax3.XTickLabel = ticklabels(2:end);
ax3.XLim = [.5 4.5];

ax3.YTick = [0 .5 1 1.5];
ax3.YLim = [0 1.2];
ax3.YTickLabel = [0 .5 1 + stop - start - width 1.5 + stop - start - width];
titles = ["Actions per trial", "Success rate", "Trial type selection"];
ylabels = ["N_{Actions}" "Successful trials [%]", "D_{KL}(observed || model)"];

for i = 1:3
    my_ax(i).TitleHorizontalAlignment = "left";
    my_ax(i).Title.FontWeight = "normal";
    my_ax(i).Title.String = titles(i);
    my_ax(i).YLabel.String = ylabels(i);
    my_ax(i).Title.Units = 'normalized';
    my_ax(i).Title.Position(2) = 1.05;
end

