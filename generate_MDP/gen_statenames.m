function state_names = gen_statenames(position_names, ...
    orientation_names, reward_types)
% JN 2021-03-04 set interaction areas to a fixed value of 7
% JN 2021-03-08 it is computationally impossible to work with current and
% previous IA, the transition matrices would be too big
% JN 2022-12-22 the above comment is not true anymore
% JN 2022-12-22 add information about which kind of area was activated

n_pos = length(position_names);
n_ias = 7;
n_ias_prev = n_ias;
n_orients = length(orientation_names);
n_rew_types = length(reward_types); % positive rewards for A, B, C, and punishment

c = 1;

state_names = cell(n_pos * n_orients * n_ias * n_ias_prev * n_rew_types, 1);

for i = 1:n_pos
    for j = 1:n_orients
        for k = 0:(n_ias-1)
            for l = 0:(n_ias_prev-1)
                for m = 1:n_rew_types
                    state_names{c} = sprintf('%s_%s_%d_%d_%s', position_names{i}, ...
                        orientation_names{j}, k, l, reward_types(m));
                    c = c + 1;
                end
            end
        end
    end
end