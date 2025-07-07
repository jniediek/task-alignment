function [possible_transitions_reward, possible_transitions_all] = find_possible_transitions(P, relevant_actions)
% JN 2023-01-11
% The idea is that the costs should be stored only for in-state out-state
% pairs that can ever occur

n_actions = size(P, 1);
n_states = size(P{1}, 1);

possible_transitions_reward = zeros(n_states, n_states);
possible_transitions_all = zeros(n_states, n_states);

for k = 1:n_actions
    Ploc = P{k};
    Ploc_binary = Ploc > 0;
    if ismember(k, relevant_actions)
        possible_transitions_reward = possible_transitions_reward | Ploc_binary;
    end

    possible_transitions_all = possible_transitions_all | Ploc_binary;
end