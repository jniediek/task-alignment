% inspired by
% https://www.mathworks.com/matlabcentral/fileexchange/68314-statistical-significance-line
function pstarbar(ax, x1, x2, y, mytext)

if isnumeric(mytext)
    if mytext < .001
        lbl = '***';
    elseif mytext < .01
        lbl = '**';
    elseif mytext < .05
        lbl = '*';
    else
        lbl = 'n.s.';
    end
else
    lbl = mytext;
end

lw = 1.5;

plot(ax, [x1 x2], [1 1] * y, 'Color', 'k', 'LineWidth', lw)

text(ax, mean([x1 x2]), y, lbl, 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', 'VerticalAlignment', 'bottom')
