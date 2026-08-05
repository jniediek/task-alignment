function ax = fig06_stub_panel(pos, txt, options)
% JN 2026-08-05
% Placeholder for a panel of figure 6 that has not been written yet.
%
%   AX = FIG06_STUB_PANEL(POS, TXT, OPTIONS) draws an empty framed box at the
%   normalized position POS = [left bottom width height], labelled with TXT, so
%   FIG06 produces the full page layout while individual panels are still being
%   ported. Delete the call once the panel is real.

ax = axes('Position', pos);
ax.XTick = [];
ax.YTick = [];
ax.Box = "on";
ax.XColor = .7 * [1 1 1];
ax.YColor = .7 * [1 1 1];

text(ax, .5, .5, txt, 'Units', 'normalized', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'Color', .5 * [1 1 1], 'FontSize', options.LabelSize, ...
    "FontName", options.FontName);
