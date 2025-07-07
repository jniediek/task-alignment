function P_sparse = create_P(pos_names, pos_codes, orient_codes, ia_curr_codes, ...
    ia_prev_codes, action_names, rew_codes, is_movement, state_names)


n_states = size(pos_names, 1);
n_actions = size(action_names, 1);

% debug mode: create P_sparse for one value of i only
debug = false;
if debug
    in_state = "A1_CLW_1_0_P";
    iterate_over = find(strcmp(state_names, in_state));
    fprintf('Looking only at instate %d\n', iterate_over);
else
    iterate_over = 1:n_states;
end




P_sparse = cell(n_actions, 1);
% t_total = 0;
tic

for k = 1:n_actions
    action = action_names{k};
    is_movement_k = is_movement(k);
    P_local = zeros(n_states, n_states);
    for i = iterate_over

        if mod(i, 1000) == 0
            t = toc;
            t_total = t;
            fprintf('%.1f %% %.1f sec\n', (i-1)/n_states * 100, t_total);
        end
        
        pos_in = pos_names(i, :);
        pos_in_1 = pos_codes(i, 1);
        pos_in_2 = pos_codes(i, 2);
        orient_in = orient_codes(i);
        ia_curr_in = ia_curr_codes(i);
        ia_prev_in = ia_prev_codes(i);
        rew_in = rew_codes(i);
        
        for j = 1:n_states
            pos_out = pos_names(j, :);
            pos_out_1 = pos_codes(j, 1);
            pos_out_2 = pos_codes(j, 2);
            orient_out = orient_codes(j);
            ia_curr_out = ia_curr_codes(j);
            ia_prev_out = ia_prev_codes(j);
            rew_out = rew_codes(j);
            
            
            P_local(i, j) = P_function(pos_in, ...
                pos_in_1, pos_in_2, orient_in, ...
                ia_curr_in, ia_prev_in, pos_out, ...
                pos_out_1, pos_out_2, orient_out, ...
                ia_curr_out, ia_prev_out, rew_in, rew_out, action, is_movement_k);
        end
    end
    P_sparse{k} = sparse(P_local);
end

dt = toc;
fprintf('Generating P took %.1f sec\n', dt);
