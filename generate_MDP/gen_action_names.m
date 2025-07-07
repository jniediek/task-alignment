function actions = gen_action_names(position_names)

% possible actions are going to a position or interacting
% JN 2019-07-16
% add option to stay
% JN 2021-03-04
% reduce eating/drinking to two actions

n_pos = length(position_names);
actions = cell(n_pos + 3, 1);

actions(1:n_pos) = position_names;

actions{n_pos + 1} = 'WA';
actions{n_pos + 2} = 'FD';
actions{n_pos + 3} = 'AC';
actions{n_pos + 4} = 'TO';
