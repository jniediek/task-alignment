function fig02_b(pos, S, options)
all_pos = cell(2, 1);

inner_w = pos(3)*.9;
inner_h = pos(4)*.8 /2 ;
hgap = pos(4)*.2/2;

for irow = 1:2
    all_pos{irow} = [pos(1) pos(2) + (2 - irow) * (inner_h + hgap) ...
        inner_w inner_h];
end

xaxis = S.Betas;

va = [["top" "bottom"]; ["bottom" "top"]];

for i_st = 1:2
    select_actions = S.select_actions(i_st, :);
    state = S.states_long(i_st);
    state_num = strcmp(S.states, state);
    data = S.res(state_num, 1, :, select_actions);
    data = squeeze(data);

    ax = axes('Position', all_pos{i_st});
    ax.NextPlot = "add";
    for i_ac = 1:2

        prob = data(:, i_ac);
        internal_idx = S.select_actions_idx(i_st, i_ac);
        plot(ax, xaxis, prob, 'LineWidth', 1.5, 'Color', ...
            options.ActionColors(internal_idx, :));
        text(ax, xaxis(140), prob(140), S.action_names(internal_idx), ...
            'Color', options.ActionColors(internal_idx, :), ...
            'VerticalAlignment', va(i_st, i_ac));
    end

    ax.Box = "off";

    ax.YLim = [0 1];
    if i_st == 1
        ax.XTickLabel = [];

    else
        ax.XLabel.String = "\beta";
    end

    ax.YTick = 0:.2:1;
    ax.YGrid = "on";
    n_sel_pol = length(S.pol_nums);
    for i_pol = 1:n_sel_pol
        xval = xaxis(S.pol_nums(i_pol));
        xline(xval, 'Color', options.TitleColors(i_pol, :), ...
            'LineStyle', '--', 'LineWidth', 1.5)
        if i_st == 1
            text(xval, 1.2, sprintf('%.3f', xval),  'Color', options.TitleColors(i_pol, :), ...
                'Rotation', 90);
        end
    end
    ax.XLim = [xaxis(1)*.8 xaxis(end)/.8];
    ax.XScale = "log";
end

text(ax, -.2, .5, 'Action probability', 'Rotation', 90, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
    'Units', 'normalized')