function fig02_a(pos, S, options)

inner_w = pos(3)*.9 / 4;
inner_h = pos(4)*.8 /2 ;
wgap = pos(3)*.1/4;
hgap = pos(4)*.2/2;
all_pos = cell(2, 4);

for irow = 1:2
    for icol = 1:4
        all_pos{irow, icol} = [pos(1) + (icol-1) * (inner_w + wgap) ...
            pos(2) + (2 - irow) * (inner_h + hgap) ...
            inner_w inner_h];
    end
end

titles = ["Almost uniform" "Low I(\pi)" "Intermediate I(\pi)" "High I(\pi)"];
states = ["B2 2" "B2 0"];


for i_st = 1:2
    state = S.states_long(i_st);
    state_num = strcmp(S.states, state);
    data = S.res(state_num, 1, :, S.action_nums);
    data = squeeze(data);

    for i_pol = 1:4
        this_pol = S.pol_nums(i_pol);
        ax = axes('Position', all_pos{i_st, i_pol});
        ax.NextPlot = "add";
        probs = data(this_pol, :);

        for kr = 1:length(S.action_nums)
            bar(kr, probs(kr), 'EdgeColor', 'none', 'BarWidth', .9, 'FaceColor', ...
                options.ActionColors(kr, :))
        end
        ax.XTick = 1:length(S.action_nums);
        ax.XTickLabel = S.action_names;
        ax.XTickLabelRotation = 90;
        ax.YLim = [0 1];
        ax.Box = 'off';
        ax.YTick = 0:.2:1;
        ax.YGrid = "on";

        if i_st == 1
            ax.Title.String = [titles(i_pol) ...
                sprintf('\\beta = %.3f',S.Betas(this_pol))];
            ax.Title.Color = options.TitleColors(i_pol, :);
        end
        if i_pol > 1
            ax.YTickLabel = [];
        end
        if i_pol == 1
            ax.YLabel.String = strcat("State ", states(i_st));
            ax.YLabel.FontWeight = "bold";


            if (i_st == 2)
                text(ax, -.5, .5, 'Action probability', 'Rotation', 90, ...
                    'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
                    'Units', 'normalized')

                text(ax, .5, -.3, 'Actions', 'HorizontalAlignment', 'center', ...
                    'Units', 'normalized')
            end
        end
    end
end