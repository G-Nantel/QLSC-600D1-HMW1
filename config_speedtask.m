function P = config_speedtask
% CONFIG_SPEEDTASK — central parameters

Screen('Preference','SkipSyncTests',0);   % 0 for real runs; 1 only for quick dev

% Display
P.whichScreen = 0;
P.bgGray      = 128;
P.winRect     = [0 0 800 800];
P.showProgress = true;   % show "answered/total (percent)" while spinning


% Stimulus
P.sphereRadius         = 100;
P.nLines               = 12;
P.presentationDuration = 1.0;    % kept for completeness (not used when spinning until response)
P.isiDuration          = 0.5;
P.refSpeed             = pi;

% ===== Forced-choice friendly levels (NO zero by default) =====
P.includeZeroDiffCatch = false;   % set true to add a few 0-diff catch trials
baseDiffs = [ ...
    pi/12,  pi/8,  pi/6, ...     % near threshold (denser)
    pi/5,   pi/4,  3*pi/8, pi/2  % mid → easy
];
if P.includeZeroDiffCatch
    P.speedDiffs = [0, baseDiffs];
else
    P.speedDiffs = baseDiffs;
end

% Repeats (total trials = numel(P.speedDiffs) * trialsPerLevel)
P.trialsPerLevel = 20;

% Rendering
P.FRONT_CULL = true;

% ===== Response-while-viewing behavior =====
P.spinUntilResponse = true;     % keep spheres spinning until 1/2 is pressed
P.maxTrialSec       = 15;       % hard safety cap (seconds)
P.showHUD           = true;     % overlay "1=Left, 2=Right" while spinning

% Output
P.outDir        = 'trial_csv';
P.participantID = getenv('USER'); if isempty(P.participantID), P.participantID = 'anon'; end
end
