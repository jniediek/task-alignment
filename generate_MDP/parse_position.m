function [idx, num] = parse_position(pos)

% simple position parser
letter_idx = 'ABCD';

idx = strfind(letter_idx, pos(1));

if length(pos) > 1
    num = str2double(pos(2));
else
    num = 1;
end