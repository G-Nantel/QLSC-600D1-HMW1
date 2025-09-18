function P = config_speedtask
% CONFIG_SPEEDTASK — central parameters (minimal + tidy outputs)

%% Psychtoolbox prefs
Screen('Preference','SkipSyncTests',0);   % 0 for real runs; 1 only for quick dev

%% Display
P.whichScreen  = 0;
P.bgGray       = 128;
P.winRect      = [0 0 800 800];          % comment this line for full-screen
P.showProgress = true;                   % show "answered/total (percent)" HUD

%% Stimulus & timing
P.sphereRadius = 100;                    % px
P.nLines       = 12;
P.isiDuration  = 0.5;                    % s
P.refSpeed     = pi;                     % rad/s

% Levels (non-negative |Δ|); side assignment randomized in do_trial
P.includeZeroDiffCatch = false;          % set true to prepend Δ=0 catch trials
P.speedDiffs = [pi/12, pi/8, pi/6, pi/5, pi/4, 3*pi/8];
% Uneven repeats to emphasize threshold region
P.repeatsPerLevel = [8, 8, 8, 6, 5, 5];  % ≈ 40 trials
% (For ~60 trials: [12, 12, 12, 10, 8, 6])

%% Rendering / behavior
P.FRONT_CULL        = true;   % <-- draw only the front hemisphere (fixes your error)
P.spinUntilResponse = true;   % keep spinning until 1/2 is pressed
P.maxTrialSec       = 15;     % safety cap (s)
P.showHUD           = true;   % overlay "1=Left, 2=Right" while spinning

%% Output locations
P.resultsDir       = 'test_run_trials';                 % session CSV/MAT live here
P.visualsDir       = 'visuals';                         % per-run PNGs here
P.writePerTrialCSV = false;                             % single CSV only (no per-trial)
P.outDir           = fullfile(P.resultsDir,'per_trial');% used only if ^ is true

%% Participant
P.participantID = getenv('USER'); if isempty(P.participantID), P.participantID = 'anon'; end
end
