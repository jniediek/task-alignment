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

Panels B, D and E are finished. Panels A, C and F are labelled placeholders; the
`fig06_*.m` file for each one documents what it will show and which data it will need.

`fig06/fig06_beta_cohort_stats.m` is a separate statistics script, not part of the
figure. It backs the claims made about panel E with permutation tests and bootstrap
confidence intervals, and is the only code in this repository that requires the
Statistics and Machine Learning Toolbox.
