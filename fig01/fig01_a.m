function fig01_a(ax, options)
options.FontWeight = "bold";
axes(ax);
im = imread('arena_downscaled.tif');
imshow(im);
text(.65, .9, "Camera", "Units", "normalized", 'Color', ...
    options.LabelColor, 'FontSize', options.LabelSize, ...
    "FontName", options.FontName, 'FontWeight', options.FontWeight);