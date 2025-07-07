function  MDP = prepare_for_g_learning(MDP)
% JN 2021-03-22
% JN 2021-07-01 removed reward action parameter

reward_actions = MDP.reward_actions;

n_states = size(MDP.P{1}, 1);
n_actions = length(MDP.P);

possible_by_state = zeros(n_states, n_actions);

for i_a = 1:n_actions
    P_t = MDP.P{i_a};
    possible_by_state(:, i_a) = any(P_t, 2);
end

possible_by_state_cell = cell(n_states, 1);
n_possible_by_state = zeros(n_states, 1);

default_policy = zeros(n_states, n_actions);


for i_s = 1:n_states
    possible_by_state_cell{i_s} = find(possible_by_state(i_s, :));
    n_possible_by_state(i_s) = length(possible_by_state_cell{i_s});
    default_policy(i_s, possible_by_state_cell{i_s}) = 1/n_possible_by_state(i_s);
end

out_states = cell(n_states, n_actions);
n_out_states = zeros(n_states, n_actions);

for i_s = 1:n_states
    for i_a = 1:n_actions
        out_states{i_s, i_a} = find(MDP.P{i_a}(i_s, :));
        n_out_states(i_s, i_a) = length(out_states{i_s, i_a});
    end
end


MDP.n_states = n_states;
MDP.n_actions = n_actions;
MDP.possible_actions = possible_by_state_cell;
MDP.n_possible_actions = n_possible_by_state;
MDP.possible_out_states = out_states;
MDP.n_possible_out_states = n_out_states;
MDP.default_policy = default_policy;
MDP.reward_actions = reward_actions;