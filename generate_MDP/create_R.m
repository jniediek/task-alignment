function R_cell = create_R(pos_names, pos_codes, orient_codes, ...
    ia_curr_codes, ia_prev_codes, action_names, is_movement, rew_codes, rew_sizes, ...
    relevant_actions, possible_transitions)
t = 0;

n_states = size(pos_names, 1);
n_relevant_actions = length(relevant_actions);
R_cell = cell(n_relevant_actions, 1);

tic
for k = 1:n_relevant_actions
    this_R = zeros(n_states, n_states);
    
    for i = 1:n_states
        if mod(i, 50) == 0
            fprintf('%.1f %% %.1f sec\n', ((i-1)/n_states/n_relevant_actions + ...
                (k-1)/n_relevant_actions) * 100, t);
        end
        pos_in = pos_names(i, :);
        pos_in_1 = pos_codes(i, 1);
        pos_in_2 = pos_codes(i, 2);
        orient_in = orient_codes(i);
        ia_curr_in = ia_curr_codes(i);
        ia_prev_in = ia_prev_codes(i);
        rew_in = rew_codes(i);
        possible_outstates = find(possible_transitions(i, :));
        for j = 1:possible_outstates
            %state_out = state_names{j};
            pos_out = pos_names(j, :);
            pos_out_1 = pos_codes(j, 1);
            pos_out_2 = pos_codes(j, 2);
            orient_out = orient_codes(j);
            ia_curr_out = ia_curr_codes(j);
            ia_prev_out = ia_prev_codes(j);
            anum = relevant_actions(k);
%             rew_out = rew_codes(j);
            
            action = action_names{anum};
            this_R(i, j) = R_function(pos_in, ...
                pos_in_1, pos_in_2, orient_in, ...
                ia_curr_in, ia_prev_in, pos_out, ...
                pos_out_1, pos_out_2, orient_out, ...
                ia_curr_out, ia_prev_out, rew_in, action, is_movement(anum), rew_sizes);
        end
        
    t = toc;
    end
    
    R_cell{k} = sparse(this_R);
    
end

dt = toc;
fprintf('Generating R took %.1f sec\n', dt);