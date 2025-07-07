% JN 2023-02-05
% lower the overall reward sizes so that the orientation cost doesn't have
% to be too high

position_names = gen_pos_names();
action_names = gen_action_names(position_names);
orientation_names = {'INW', 'CLW', 'OUT', 'CCW'};
reward_types = 'ABCP';
state_names = gen_statenames(position_names, orientation_names, reward_types);

[pos_names, pos_codes, orient_codes, ia_curr_codes, ia_prev_codes, ...
    rew_codes, is_movement] = ...
    create_codes(state_names, action_names, orientation_names);

rew_sizes.water = 30 * ones(6, 1);
rew_sizes.food = 30 * ones(6, 1);
rew_sizes.poke = 0 * ones(6, 1);

% specific implementation of the different reward sized for A, B, and C
rew_sizes.B_factor = 1.5;
rew_sizes.C_factor = 1.25;


% these are the movement costs.
% the orientation costs are currently coded directly in the corresponding
% function
cost_A_next_B = 1;
cost_A_next_C = 1.5;
cost_B_next_C = 1.5;

costs{1, 1} = [2 4 6];
costs{1, 2} = [cost_A_next_B 2 4 5];
costs{1, 3} = [cost_A_next_C 3 5];
costs{1, 4} = 2;
costs{2, 2} = [2 4 5];
costs{2, 3} = [cost_B_next_C, 3 5];
costs{2, 4} = 1;
costs{3, 3} = costs{2, 2};
costs{3, 4} = 1;
%%

P = create_P(pos_names, pos_codes, orient_codes, ia_curr_codes, ...
    ia_prev_codes, action_names, rew_codes, is_movement);

%
save('P_2023-06-15.mat', 'P')

%%
S = load('P_2023-06-15.mat');
P = S.P;
%%
relevant_actions = [20 21];

[possible_trans_rew, possible_trans_all] = find_possible_transitions(P, relevant_actions);

R = create_R(pos_names, pos_codes, orient_codes, ia_curr_codes, ...
    ia_prev_codes, action_names, is_movement, rew_codes, rew_sizes, relevant_actions, possible_trans_rew);


%% now the costs

% because of memory requirements, C should not be copied to each state!
% what we need is PR for the deterministic solutions and a trajecotry
% generator

% let's create a matrix of possible state transitions, and let's save MC
% and OC only for these

[MC, OC] = create_C(pos_codes, orient_codes, costs, possible_trans_all);
MC = sparse(MC);
OC = sparse(OC);
%%

MDP.names_positions = position_names;
MDP.names_actions = action_names;
MDP.names_orientations = orientation_names;
MDP.names_states = state_names;
MDP.rew_sizes = rew_sizes;
MDP.movement_costs = costs;
MDP.P = P;
MDP.R = R;
MDP.MC = MC;
MDP.OC = OC;
MDP.possible_trans_all = possible_trans_all;
MDP.posssible_trans_rew = possible_trans_rew;

% "real R of the MDP": R - MC - OC
% An MDP is defined by the full state transition matrix and full
% cost/reward matrix

MDP.reward_actions = relevant_actions;


MDP = prepare_for_g_learning(MDP);
outfolder = '~/Repositories/mdp/results/mdp_maciej_23_actions/mdps_2023';

dstr = datestr(now, 'yyyy-mm-dd');
fname = sprintf('MDP_Maciej_%s_pk0.mat', dstr);
save(fullfile(outfolder, fname), 'MDP');