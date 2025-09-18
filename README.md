# QLSC-600D1-HMW1
Homework 1 - Psychophysics
# Speed Discrimination Task (2AFC)

A minimal Psychtoolbox experiment where participants judge which of two rotating striped spheres spins faster by pressing **1 (Left)** or **2 (Right)** **while the stimulus is visible**. The script records responses and reaction times and writes **one final CSV + MAT** per session.

---

## Why this exists

* **Measure sensitivity** to small speed differences using an **unsigned psychometric function** (proportion correct vs |Δ|).
* **Efficient design**: sample more densely near threshold; keep total trials modest (≈40–60) without losing curve quality.
* **Low friction**: answer during viewing to reduce memory load and speed up sessions.

---

## Requirements

* MATLAB R2018b+ (tested on recent versions)
* [Psychtoolbox](http://psychtoolbox.org/) installed and working (run `AssertOpenGL` in MATLAB to verify)
* macOS/Windows/Linux supported

---

## Files

```
main_speedtask.m         % entrypoint; runs session; writes final CSV/MAT
config_speedtask.m       % parameters (display, levels, repeats, behavior flags)
do_trial.m               % single-trial logic (answer while viewing; RT from onset)
finalize_session.m       % plots PropCorrect vs |Δ| and saves session CSV/MAT
drawSphereMeridians.m    % helper: left sphere stripes
drawSphereLatitudes.m    % helper: right sphere stripes
```

---

## Quick start

```matlab
addpath(genpath(pwd));   % if you're already in the repo folder
main_speedtask           % run the experiment
```

**Respond:** `1` = Left faster, `2` = Right faster. Press `ESC` to abort.

**Output:** One CSV and one MAT named like `participant_session_YYYYMMDD_HHMMSS.csv/.mat`.

> **External display:** set `P.whichScreen = max(Screen('Screens'))` in `config_speedtask.m`. Comment out `P.winRect` for full-screen.

---

## Config essentials (`config_speedtask.m`)

```matlab
Screen('Preference','SkipSyncTests',0);   % 0 for real runs; 1 only for quick dev
P.whichScreen  = 0;                        % display index
P.winRect      = [0 0 800 800];            % comment this line for full-screen
P.showProgress = true;                     % show "answered/total (percent)"

% Stimulus & timing
P.sphereRadius = 100;   P.nLines = 12;
P.isiDuration  = 0.5;   P.refSpeed = pi;   % rad/s

% Levels (non-negative |Δ|); side assignment randomized in do_trial
P.includeZeroDiffCatch = false;            % set true to add Δ=0 catch trials
P.speedDiffs = [pi/12, pi/8, pi/6, pi/5, pi/4, 3*pi/8];

% Repeats per level (uneven to emphasize threshold region)
P.repeatsPerLevel = [8, 8, 8, 6, 5, 5];   % ≈ 40 trials total
% (Or for ~60 trials: [12, 12, 12, 10, 8, 6])

% Behavior: answer while viewing
P.spinUntilResponse = true;    % keep spheres spinning until keypress
P.maxTrialSec       = 15;      % safety cap per trial (sec)
P.showHUD           = true;    % overlay "1=Left, 2=Right (ESC)"

% Output (single final CSV/MAT; per-trial CSVs disabled by default)
P.writePerTrialCSV  = false;   % set true only if you need per-trial files
P.outDir = 'trial_csv';        % used only when writePerTrialCSV=true
```

---

## Data columns (session CSV)

| Column                                 | Description                                    |
| -------------------------------------- | ---------------------------------------------- |
| `ConditionIndex`                       | index into `P.speedDiffs`                      |
| `SignedDiff_rad_s`                     | `testSpeed - P.refSpeed` (signed)              |
| `AbsDiff_rad_s`                        | `abs(SignedDiff_rad_s)`                        |
| `LeftHasReference`                     | `true` if left sphere used the reference speed |
| `SpeedLeft_rad_s` / `SpeedRight_rad_s` | actual speeds shown                            |
| `Response`                             | 1 = Left faster, 2 = Right faster              |
| `RT_s`                                 | reaction time from stimulus onset              |
| `Correct`                              | 1 if response matched the faster side          |

A corresponding MAT file with the same variables is also saved.

---

## Analysis

* Built-in plot: **Proportion correct vs |Δ|** (unsigned psychometric function).
* For thresholds, fit a Weibull (γ≈0.5, small λ) at \~75% correct using Palamedes or similar.

---

## Tips & Troubleshooting

* **Sync tests:** Use `SkipSyncTests=1` for quick dev only; keep `0` for real timing.
* **Keys on macOS:** grant MATLAB Accessibility/Input Monitoring permissions.
* **Too hard/easy:** adjust smallest/largest `P.speedDiffs` and/or `repeatsPerLevel`.
* **Motivation:** enable `P.showProgress` to show `answered/total` and percent done.

---
