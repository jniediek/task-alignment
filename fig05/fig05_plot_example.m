function [ax1, ax2] = fig05_plot_example(pos, info, beta_struct, options)

% JN 2023-09-15
% plot example of a beta time course and unit firing time course
% create three axes

% pos = pos_a;
w_pos = pos(3);
h_pos = pos(4);

rel_w_left = .4;
rel_w_right = .4;
rel_h_right = 1;

abs_w_left = w_pos * rel_w_left;
abs_w_right = w_pos * rel_w_right;
abs_h_right = h_pos * rel_h_right;

pos_left = [pos(1) pos(2) abs_w_left pos(4)];
pos_right_bot = [pos(1) + pos(3) - abs_w_right, pos(2), abs_w_right abs_h_right];
% pos_right_top = [pos(1) + pos(3) - abs_w_right, pos(2) + pos(4) - abs_h_right abs_w_right abs_h_right];


ax1 = axes('Position', pos_left);
ax2 = axes('Position', pos_right_bot);
%
beta_idx = (beta_struct.meta.Date == info.Date) & (beta_struct.meta.Rat == info.Rat);
% assert(sum(beta_idx) == 1);

beta_info = beta_struct.policy_info.Beta;

t_beta = beta_struct.all_betas(:, beta_idx);
% t_beta = beta_info();
beta_ok = ~isnan(t_beta);
beta_val = nan(length(t_beta), 1);
beta_val(beta_ok) = beta_info(t_beta(beta_ok));

% t_times = beta_struct.start_times{beta_idx};
t_fr = beta_struct.fr_averaged(:, info.UnitExtern);


if ismember(info.Rat, [7 8])
    layoutfile = '../data/Cambridge_Neurotech_32x2_old_layout.mat';
elseif ismember(info.Rat, [4 5])
    layoutfile = '../data/Cambridge_Neurotech_32x2_new_layout.mat';
end
layout = load(layoutfile);

fname = sprintf('%s_Rat-%d_Unit-%02d.mat', info.Date, info.Rat, ...
    info.UnitIntern);
S = load(fullfile('../data', fname));
waveforms = S.waveforms;
if size(waveforms, 2) < 200
    return
end
elec_num = S.elec_num;

samples_to_plot = 10:50;


ax1.NextPlot = "add";

rel_kcoord = layout.kcoords(elec_num);


v_factor = .125;
for chan = 1:32
    if layout.kcoords(chan) ~= rel_kcoord
        continue
    end
    
    if chan == elec_num
        color = 'm';
    elseif layout.kcoords(chan) == rel_kcoord
        color = 'k';
    else
        color = .6 * [1 1 1];
    end
    temp_chan = v_factor * squeeze(waveforms(chan, 100:200, samples_to_plot));
    temp_chan(abs(temp_chan) > 50) = nan;
    plot(ax1, samples_to_plot + layout.xcoords(chan), ...
        temp_chan + layout.ycoords(chan), 'Color', color)
end
ax1.XColor = 'none';
ax1.YColor = 'none';
ax1.XTickLabels = [];
ax1.YTickLabels = [];

% xbar =  layout.xcoords(elec_num);
if layout.kcoords(elec_num) == 1
    xsh = -36;
else
    xsh = 264;
end


if options.plot_label
    
    plot(ax1, [xsh xsh]-25, [-50 0] - 15, 'k', 'LineWidth', 2);
    voltmark = 50 / v_factor;
    
    text(ax1, xsh-15, -40, sprintf('50 µm / %.0f µV',voltmark));
    ax2.XLabel.String = "Time [min]";
end
%
% plot(ax1, [xsh xsh]-18, [50 100], 'k', 'LineWidth', 2);
ax1.YLim = [-65 310];
ax1.XLim = [-36 100] + xsh;
t_times = 1:50;
yyaxis(ax2, 'left');
plot(ax2, t_times, beta_val, 'Color', options.ColorBeta, 'LineWidth', 1.5);
ax2.YAxis(1).Color = options.ColorBeta;
ax2.YAxis(1).Label.String = 'Best fitting \beta';
ax2.YAxis(1).Label.FontWeight = 'bold';
yyaxis(ax2, 'right');
plot(ax2, t_times, t_fr, 'Color', options.ColorFiringRate, 'LineWidth', 1.5);
ax2.YAxis(2).Color = options.ColorFiringRate;
ax2.YAxis(2).Label.String = 'Firing rate [Hz]';
ax2.YAxis(2).Label.FontWeight = 'bold';
ax2.XTick = 0:10:50;
ax2.XGrid = "on";
ax2.Box = "off";
% scatter(ax3, t_fr, t_beta, [], t_times);

%
% ax = subplot(1, 2, 2);
% ax.NextPlot = "add";
%
% t_beta = (t_beta - mean(t_beta))/std(t_beta);
%
% plot(t_times, t_beta)

%
% all_fr = zeros(length(t_times), 1);
% for i_start = 1:length(t_times)
%     spks = (sp_times >= t_times(i_start)) & (sp_times <= t_times(i_start) + 60);
%     all_fr(i_start) = sum(spks);
% end
%
% all_fr = movmean(all_fr, 10, 'Endpoints', 'discard');
%
% all_fr = (all_fr - mean(all_fr))/std(all_fr);
%
% plot(t_times(1:50), all_fr);
%
% r = corr(all_fr, t_beta(1:50));


% options.FontWeight = "bold";
% text(0, 0, "Waveforms")