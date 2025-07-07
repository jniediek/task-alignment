function orientation = get_path_orientation(idx1, num1, idx2, num2)

% codes:
% 0, no angle
% 1, inwards
% 2, clockwise
% 3, outwards
% 4, counterclockwise

if (idx1 == num1) && (idx2 == num2)
    orientation = 0;
    return
end


% orientatation values for each pair of idxs from {A, B, C, D}
t = cell(4, 4);
t{1, 1} = [0 2 2 3 4 4];
t{1, 2} = [1 2 2 3 4 4];
t{1, 3} = [2 2 2 4 4 4];


t{1, 4} = 1;
t{2, 1} = [3 2 2 3 4 4];
t{2, 2} = t{1, 1};
t{2, 3} = t{1, 3};
t{2, 4} = t{1, 4};
t{3, 1} = [4 2 2 2 4 4];
t{3, 2} = t{3, 1};
t{3, 3} = t{1, 1};
t{3, 4} = t{1, 4};
t{4, 1} = 3;
t{4, 2} = t{4, 1};
t{4, 3} = t{4, 1};
t{4, 4} = 0;


if (idx1 == 4) || (idx2 == 4)
    rel_num = 1;
else
    rel_num = num2 - num1 + 1;
    if rel_num < 1
        rel_num = num2 - num1 + 7;
    end
end
orientation = t{idx1, idx2}(rel_num);
