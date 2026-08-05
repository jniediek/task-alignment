# Code related to the preprint *Insular cortex encodes task alignment*

This repository contains code related to the preprint

**Insular cortex encodes task alignment**

Johannes Niediek, Maciej M. Jankowski, Ana Polterovich, Alexander Kazakov, Israel Nelken

bioRxiv 2024.12.13.628250; doi: [https://doi.org/10.1101/2024.12.13.628250](https://doi.org/10.1101/2024.12.13.628250)

## Instructions 
The code was tested with Matlab R2024a. The code generates the figures in the paper. There is a folder for each figure, navigate Matlab to the folder and run the function called `fig01.m`, `fig02.m`, etc. The figures are saved as PNG files.

## Figure 6

Figure 6 covers the human number-guessing-game analyses. Unlike the other figures, its
values are not precomputed: `fig06.m` fits the task-alignment parameter beta at render
time from `data/fig06_policy.mat` (the beta grid, the policy tensor, and the per-beta
`Value` and `Complexity`) and `data/fig06_steps.mat` (the choice steps of 228 subjects),
via `compute_cohort_betas.m` and `fit_subject_betas.m`.

Panels B to F are finished. Panel A is a labelled placeholder; `fig06_task_schematic.m`
documents what it will show.

Panel F departs from the Python reference in one deliberate way: its model curve is computed
exactly by `fig06/exact_steps_moments.m`, by a forward recursion over the state chain, rather
than estimated by simulating games. The reachable states always shrink, so the recursion
needs one sweep and carries no sampling noise.

Panels B and C share a selection of four policies, set as `options.pol_nums` in `fig06.m`:
panel C draws them and panel B marks them on its curve, in the same colours.

### A known flaw in the solved policy

The guessing-game MDP is exactly symmetric under `a -> n+1-a`: guessing the a-th smallest
of n candidates and guessing the a-th largest leave mirror-image intervals with mirror-image
probabilities. The solution must inherit that symmetry, so the best guess is the balanced
split `(n+1)/2` — ordinary binary search.

The policy in `data/fig06_policy.mat` does not quite satisfy this. The deviation is at
machine level at `beta = 0`, where the policy is the uniform prior, and grows with both beta
and the interval length, reaching about a quarter of the peak probability at `beta = 2` and
`n = 100`; the curves in panel C consequently peak at rank 53 of 100 rather than at 50/51.
This is under-convergence in the G-learning solve, not a property of the task.

`fig06/check_policy_symmetry.m` measures the violation and prints it whenever the figure is
built. The policy is **not** corrected: every fit uses it as solved, so the estimates match
the reference implementation. Symmetrizing the policy would move the cohort mean beta by
less than half a step of the beta grid.

`fig06/fig06_beta_cohort_stats.m` is a separate statistics script, not part of the
figure. It backs the claims made about panel E with permutation tests and bootstrap
confidence intervals, and is the only code in this repository that requires the
Statistics and Machine Learning Toolbox.
