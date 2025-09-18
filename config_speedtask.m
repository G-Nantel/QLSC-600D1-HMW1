function P = config_speedtask
% CONFIG_SPEEDTASK — central parameters (minimal + clear)

%% Psychtoolbox prefs
Screen('Preference','SkipSyncTests',0);   % 0 for real runs; 1 only for quick dev

%% Display
P.writePerTrialCSV = false;   % <- do NOT write a CSV per trial
P.whichScreen  = 0;
P.bgGray       = 128;
P.winRect      = [0 0 800 800];          % comment this line for full-screen
P.showProgress = true;                   % show "answered/total (percent)" HUD

%% Stimulus
P.sphereRadius         = 100;            % px
P.nLines               = 12;
P.presentationDuration = 1.0;            % only used if spinUntilResponse=false
P.isiDuration          = 0.5;            % s
P.refSpeed             = pi;             % rad/s

% Forced-choice friendly |Δ| levels (no zero by default)
P.includeZeroDiffCatch = false;          % set true to prepend a few 0-diff catches
baseDiffs = [ ...
    pi/12,  pi/8,  pi/6, ...            % near-threshold (denser)
    pi/5,   pi/4,  3*pi/8               % mid → easy anchor
];
if P.includeZeroDiffCatch
    P.speedDiffs = [0, baseDiffs];
else
    P.speedDiffs = baseDiffs;
end

% Uneven repeats: spend trials near threshold (total ≈ 60)
%              [  pi/12   pi/8   pi/6   pi/5   pi/4   3pi/8 ]
P.repeatsPerLevel = [   12,     12,     12,     10,     8,     6  ];
% If you'd rather use a single number for all levels, delete the line above
% and set: P.trialsPerLevel = 20;   % (main_speedtask falls back to this)

%% Rendering / response behavior
P.FRONT_CULL        = true;   % draw only front hemisphere
P.spinUntilResponse = true;   % keep spinning until 1/2 is pressed
P.maxTrialSec       = 15;     % safety cap (s)
P.showHUD           = true;   % overlay "1=Left, 2=Right" while spinning

%% Output
P.outDir        = 'trial_csv';
P.participantID = getenv('USER'); if isempty(P.participantID), P.participantID = 'anon'; end
end
