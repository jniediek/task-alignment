function ax = fig06_task_schematic(pos, options)
% JN 2026-08-05
% Panel A of figure 6: explanation of the number-guessing task.
%
%   AX = FIG06_TASK_SCHEMATIC(POS, OPTIONS) draws into a new axes at the
%   normalized position POS = [left bottom width height].
%
%   NOT YET WRITTEN -- currently a placeholder.
%
%   The panel will be an illustration drawn outside MATLAB and dropped into
%   this folder, shown with IMREAD / IMSHOW into the panel axes, in the manner
%   of FIG01_A (fig01/fig01_a.m), with any labels added as normalized-units
%   TEXT on top.
%
%   The task: an interval-halving guessing game. At each guess the subject
%   faces an interval of s still-possible numbers (the MDP state, s = 1..100),
%   and a guess is encoded as its 1-indexed rank a within that interval.
%   P(correct) = 1/s, P(too high) = (a-1)/s giving next state a-1, and
%   P(too low) = (s-a)/s giving next state s-a. A solved game restarts at
%   s = 100.

ax = fig06_stub_panel(pos, 'Explanation of the task', options);
