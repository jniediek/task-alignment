function fig01_trial_trajectory(ax, ax_text, S)

bg = S.bg;
R = S.R;
zones = S.zones;

rel_trials = S.rel_trials;
loc_arr = S.loc_arr;
tab_sorted = S.tab_sorted;
t_frames_loc = S.t_frames_loc;
t_seq = S.t_seq;

scatter_size = 6;
tr_to_color = containers.Map(["A" "B" "C" "warning"], [1 2 3 4]);
trial_colors = ["#ffa116", "#ff25c8", "#00c0ff", "#ff0000"];

ax.NextPlot = "add";
ax_text.NextPlot = "add";
ax.XLim = [100 520];
ax.YLim = [50 450];
ax_text.Color = .5 * [1 1 1];

plot_background(ax, bg, R, zones);


tab_sorted.is_activate = false(height(tab_sorted), 1);
tab_sorted.is_activate(tab_sorted.Event == "NPWait") = 1;
tab_sorted.is_activate(tab_sorted.Event == "Warning") = 1;
count = 0;

for itr = rel_trials

    count = count + 1;
    trial_idx = tab_sorted.trial_num == itr;
    trial_times = tab_sorted.start_t(trial_idx);
    acti_idx = trial_idx & tab_sorted.is_activate;
    rel_time = tab_sorted.start_t(acti_idx);

    idx_t_pre_tgt = (t_frames_loc >= trial_times(1)) & ...
        (t_frames_loc <= rel_time(1));
    idx_t_post_tgt = (t_frames_loc >= rel_time(1)) & ...
        (t_frames_loc <= trial_times(end));

    idx_f = find(acti_idx, 1, 'first');
    tr_type = string(tab_sorted.trial_type(idx_f));

    tr_color =  trial_colors(tr_to_color(tr_type));

    idxs = {idx_t_pre_tgt, idx_t_post_tgt}; % idx_t_loc};
    colors = {tr_color, tr_color, tr_color};
    widths = [1 2 1];

    xs = loc_arr(:, 1);
    ys = loc_arr(:, 2);

    for i_part = 1:length(idxs)

        local_idx = idxs{i_part};
        color = colors{i_part};

        plot(ax, xs(local_idx), ys(local_idx), ...
            'Marker', 'none', 'MarkerEdgeColor', color, ...
            'MarkerSize', scatter_size, 'Color', color, ...
            'LineWidth', widths(i_part))
    end

    att_idx = trial_idx & tab_sorted.Event == "att_sound";
    att_time = tab_sorted.start_t(att_idx);
    att_loc_idx = find(t_frames_loc >= att_time, 1, 'first');

    plot(ax, xs(att_loc_idx), ys(att_loc_idx), 'Marker', 'v', ...
        'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'g',  ...
        'MarkerSize', 6, 'LineWidth', 2)

    [~, ind] = min(abs(t_frames_loc - rel_time));
    tx = loc_arr(ind, 1);
    ty = loc_arr(ind, 2);
    plot(ax, tx, ty, '+', 'Color', 'w', 'MarkerSize', 4, 'LineWidth', 1.8)

    % define all actions that belong to this trial
    fidx_ac = find(t_seq.trial_num == itr);

    plot(ax_text, trial_times([1 end]) - att_time, [1 1] * count, ...
        'LineWidth', 3, 'Color', tr_color);
    rel_pos = t_seq.Position(fidx_ac, :);
    text(ax_text, -.5, count, rel_pos(1, :), 'HorizontalAlignment', 'right')
    
    for i_ac = fidx_ac'
        t_seq(i_ac, :)
        [~, i] = min(abs(t_frames_loc - t_seq.start_t(i_ac)));
        x = loc_arr(i, 1);
        y = loc_arr(i, 2);

        t_ac = t_seq.Action(i_ac, :);

        lw = 2;
        do_mark = false;
        if strcmp(t_ac, 'FD')

            mec = 'w';
            mfc = 'w';
            mark = '|';
            do_mark = true;
            ms = 8;
            lw = 2;
        elseif strcmp(t_ac, 'WA')

            mfc = 'none';
            mark = '.';
            do_mark = true;
            ms = 12;
        elseif strcmp(t_ac, 'AC')
            mec =  'w';
            mfc = 'w';
            mark = '+';
            ms = 8;
            do_mark = true;

        elseif strcmp(t_ac, 'TO')
            mec = 'w';
            mfc = 'w';
            mark = "d";
            ms = 5;
            do_mark = true;
        else
            mec = '#6666ff';
            do_mark = false;
        end

        if do_mark
            plot(ax, x, y, 'Marker', mark, 'MarkerFaceColor', mfc, ...
                'MarkerSize', ms, 'MarkerEdgeColor', mec, 'LineWidth', lw, 'Color', mec)
        end

        x = t_seq.start_t(i_ac) - trial_times(1);
        y = count;
        mytext = t_seq.Action(i_ac, :);

        if (x > -3)
            if do_mark
                plot(ax_text, x, y, mark, 'MarkerFaceColor', mfc, ...
                    'MarkerSize', ms, 'MarkerEdgeColor', mec, 'LineWidth', lw, ...
                    'Color', mec);
                shift = -.3;
            else

                plot(ax_text, x, y, '.', 'MarkerFaceColor', 'w', ...
                    'MarkerSize', 11, 'MarkerEdgeColor', 'w', 'LineWidth', lw, ...
                    'Color', 'w');
                shift = -.3;
            end
            % very specific for visual appearance only:
            if strcmp(mytext, 'A5')
                x = x - .15;
            end
            text(ax_text, x, y + shift, mytext, 'HorizontalAlignment', ...
                'center', ...
                'Color', 'k', 'FontSize', 10, 'Rotation', 90, 'Color', 'w', 'FontSize', 8)
        end
        shift = 0;
        plot(ax_text, 0, y + shift, 'Marker', 'v', ...
            'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'g',  ...
            'MarkerSize', 6, 'LineWidth', 2)
    end

end

ax_text.YAxis.Direction = 'reverse';
ax_text.XLim = [-.5 10.8];
ax_text.YLim = [.5 length(rel_trials) + .5];
ax_text.XTick = 0:10;
ax_text.XLabel.String = "Time [sec]";
ax_text.YTickLabel= "";
ax_text.YTick = [];


% add information for the legend
opts = ["ATT", "AC", "Move", "FD", "TO" ];
mfc = 'w';
mec = 'w';
lgd = zeros(length(opts), 1);
for i = 1:length(opts)
    t_ac = opts(i);
    if strcmp(t_ac, "ATT")
        mark = 'v';
        ms = 6;
    elseif strcmp(t_ac, 'FD')
        mark = '|';
        ms = 8;
        lw = 2;
    elseif strcmp(t_ac, 'WA')
        mark = '.';
        ms = 12;
    elseif strcmp(t_ac, 'AC')
        mark = '+';
        ms = 8;
    elseif strcmp(t_ac, "Move")
        mark = '.';    
    elseif strcmp(t_ac, 'TO')
        mark = "d";
        ms = 5;
      
    end

    lgd(i) = plot(ax_text, x, y, mark, 'MarkerFaceColor', mfc, ...
        'MarkerSize', ms, 'MarkerEdgeColor', mec, 'LineWidth', lw, ...
        'Color', mec);
end



labels = ["Trial start" "Activate" "Movement" "Nose-poke" "Time-out"];

lgd = legend(ax_text, lgd, labels, 'Color', 'none', ...
    'TextColor', 'w', 'EdgeColor', 'w');


lgd.Position = [0.84 .305 .13 .149];