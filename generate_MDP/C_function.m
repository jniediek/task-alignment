function [mc, oc] = C_function(pos_in_1, pos_in_2, orient_in, pos_out_1, pos_out_2, ...
    orient_out, costs)


mc = gen_movement_costs(pos_in_1, pos_in_2, pos_out_1, pos_out_2, costs);

oc = gen_orientation_cost(orient_in, orient_out);
