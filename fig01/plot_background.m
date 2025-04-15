function plot_background(ax, bg, R, zones)

temp_image = min(bg * 2 + 50, 255);

temp_image = cat(3, temp_image, temp_image, temp_image);

imshow(temp_image, 'Parent', ax)

centx = 309;
centy = 243;
R = R * 1.05;

RC = R*.475;
RB = R* (0.313 + .475);

shift = 0;
zones.AngleBegin = zones.AngleBegin + shift;
zones.AngleEnd = zones.AngleEnd + shift;
zones.AngleCenter = zones.AngleCenter + shift;

gridcolor = .7*[1 1 1];
cols = {'AngleBegin', 'AngleEnd'};

gridlw = 1.5;

for i = 1:6
    for j = 1:2
        theta = zones.(cols{j})(i);
        y = sin(theta);
        x = cos(theta);
        plot(ax, [RC  R]*x + centx, [RC R]*y + centy, 'Color', gridcolor, ...
            'LineWidth', gridlw)
    end
    % plot the B separation
    xs = zones.AngleBegin(i):0.01:zones.AngleEnd(i);
    plot(ax, RB*cos(xs) + centx, RB*sin(xs) + centy, 'Color', gridcolor, ...
        'LineWidth', gridlw)
end

% draw the D area
xs = 0:.01:2*pi;
plot(ax, RC*cos(xs) + centx, RC*sin(xs) + centy, 'Color', gridcolor, ...
    'LineWidth', gridlw);

rA = .89 * R;
rB = .65 * R;
rC = rB;

textsz = 12;

for n = 1:6
    nstr = num2str(n);
    thetaAB = zones.AngleCenter(n);
    thetaC = zones.AngleCenter(n + 6);
    text(ax, rA*cos(thetaAB) + centx, rA*sin(thetaAB) + centy, ['A' nstr], 'Color', ...
        gridcolor, 'HorizontalAlignment', 'center', 'Clipping', 'on', ...
        'FontSize', textsz);
    text(ax, rB*cos(thetaAB) + centx, rB*sin(thetaAB) + centy, ['B' nstr], 'Color', ...
        gridcolor, 'HorizontalAlignment', 'center', 'Clipping', 'on', ...
        'FontSize', textsz);
    text(ax, rC*cos(thetaC) + centx, rC*sin(thetaC) + centy, ['C' nstr], 'Color', ...
        gridcolor, 'HorizontalAlignment', 'center', 'Clipping', 'on', ...
        'FontSize', textsz);
end