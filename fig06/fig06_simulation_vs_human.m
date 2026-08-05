function ax = fig06_simulation_vs_human(pos, options)
% JN 2026-08-05
% Panel F of figure 6: simulated agent against human subjects, beta over the
% average game length.
%
%   AX = FIG06_SIMULATION_VS_HUMAN(POS, OPTIONS) draws into a new axes at the
%   normalized position POS = [left bottom width height].
%
%   NOT YET WRITTEN -- currently a placeholder.
%
%   To be ported from gg_figures/code/fig02_beta_vs_avg_steps_simulation.py:
%   for every beta on the grid, simulate 1000 games under pi_beta and plot the
%   mean guesses per game with its SEM as a line; on the same axes, scatter one
%   point per human subject at that subject's fitted beta_hat and observed mean
%   guesses per game. The humans fall on the simulated curve where the model
%   describes them.
%
%   Data: ../data/fig06_policy.mat and ../data/fig06_steps.mat. The simulation
%   itself has no MATLAB port yet -- the game dynamics are the ones described in
%   FIG06_TASK_SCHEMATIC, and the Python reference is
%   beta_fitting.simulate_policy_games (SIM_SEED = 42).

ax = fig06_stub_panel(pos, 'Simulated agent vs. human', options);
