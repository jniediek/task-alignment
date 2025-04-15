function options = get_options()

options.LabelColor = [0 0 .6];
options.LabelColorLight = [.53 .8 1];
options.FontName = "Sans";
options.LabelSize = 13;
options.FontSizeLetters = 14;
options.RatColors = [[202,103,52]; ...
    [186,189,71]; ...
    [100,197,113]; ...
    [121,105,210]; ...
    [200,82,174]];
options.RatColors = options.RatColors / 255;
options.RatMarkers = 'svod^';
options.RatMarkerSize = 4;
options.HistogramFaceColor = .55 * [1 1 1];
options.FontWeight = "normal";
options.trial_colors = ["#ffa116", "#ff25c8", "#00c0ff", "#ff0000"];

c_color = .8 * [0 0.75 1];
d_color = .2 * [1 1 1];
options.ActionColors = [.8 * [1 .6 .1]; c_color; c_color; d_color;
    .5 * [0 1 0]; .5 * [1 0 0]];
options.LegendEdgeColor = .8 * [1 1 1];
