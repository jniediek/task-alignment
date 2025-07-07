function [pos_names, pos_codes, orient_codes, ia_curr_codes, ...
    ia_prev_codes, rew_codes, is_movement] = create_codes(state_names, action_names, orientation_names)
% JN 2021-03-16
% JN 2022-12-22 add reward type information

n_states = length(state_names);
n_actions = length(action_names);

pos_codes = zeros(n_states, 2);
pos_names = char(zeros(n_states, 2));
orient_codes = zeros(n_states, 1);
ia_curr_codes = char(zeros(n_states, 1));
ia_prev_codes = char(zeros(n_states, 1));
rew_codes = char(n_states, 1);

for i = 1:n_states
    state = state_names{i};
    [a, b] = parse_position(state);
    pos_codes(i, :) = [a b];
    pos_names(i, :) = state(1:2);
    orient_codes(i) = find(strcmp(state(4:6), orientation_names));
    ia_curr_codes(i) = state(8);
    ia_prev_codes(i) = state(10);
    rew_codes(i) = state(12);
end

is_movement = zeros(n_actions, 1);

for i = 1:n_actions
    action = action_names{i};
    a2 = action(2);
    is_movement(i) = ismember(a2, '123456');
end