function [MC, OC] = create_C(pos_codes, orient_codes, costs, possible_transitions)
% JN 2021-03-15, 2021-04-07
% JN 2023-01-12 added possible transitions

% MC are the movement costs
n_states = size(pos_codes, 1);
MC = zeros(n_states, n_states);

% OC are the orientation costs
OC = zeros(n_states, n_states);

t_total = 0;

tic
for i = 1:n_states
    
    if mod(i, 50) == 0
        fprintf('%.1f %% %.1f sec\n', (i-1)/n_states * 100, t_total);
    end
    pos_in_1 = pos_codes(i, 1);
    pos_in_2 = pos_codes(i, 2);
    orient_in = orient_codes(i);

    possible_outstates = find(possible_transitions(i, :));
    
    for j = possible_outstates
        
        pos_out_1 = pos_codes(j, 1);
        pos_out_2 = pos_codes(j, 2);
        orient_out = orient_codes(j);
        
        MC(i, j) = gen_movement_costs(pos_in_1, pos_in_2, ...
            pos_out_1, pos_out_2, costs);
        OC(i, j) = gen_orientation_cost(orient_in, orient_out);
        
    end
    
    t = toc;
    t_total = t;
end