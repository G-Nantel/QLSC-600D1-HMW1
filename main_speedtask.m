function main_speedtask
% MAIN_SPEEDTASK
% Minimal modular runner:
% - loads params (config_speedtask.m)
% - opens PTB safely (auto-cleanup on error/quit)
% - loops trials via do_trial.m
% - writes per-trial CSVs (unique filenames)
% - calls finalize_session.m for unsigned PF plot + session CSV/MAT
%
% Files expected in the same folder:
%   config_speedtask.m
%   do_trial.m
%   drawSphereMeridians.m
%   drawSphereLatitudes.m
%   finalize_session.m

rng('shuffle');
P = config_speedtask();

AssertOpenGL;
KbName('UnifyKeyNames');

[win, rect] = Screen('OpenWindow', P.whichScreen, P.bgGray, P.winRect);
cleanupObj = onCleanup(@() cleanupPTB()); %#ok<NASGU>  % ensure screen closes

[xC, yC] = RectCenter(rect);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% ensure output dir exists
if ~exist(P.outDir,'dir'); mkdir(P.outDir); end

% ---------------- Instructions ----------------
DrawFormattedText(win, ['Two spheres rotate.\n' ...
    '1 = LEFT faster,  2 = RIGHT faster.\nESC to quit.\n\nPress any key to start.'], ...
    'center','center',0);
Screen('Flip', win); 
KbWait;

% ---------------- Trial order -----------------
levels = 1:numel(P.speedDiffs);
order  = repelem(levels, P.trialsPerLevel);
order  = order(randperm(numel(order)));   % randomized, balanced
nT     = numel(order);

% ---------------- Session buffers -------------
levelIdx      = zeros(nT,1);
signedDiff    = zeros(nT,1);
absDiff       = zeros(nT,1);
leftIsRef     = false(nT,1);
speedLeftLog  = zeros(nT,1);
speedRightLog = zeros(nT,1);
response      = zeros(nT,1);
rt            = zeros(nT,1);
correct       = zeros(nT,1);

% Stimulus anchor positions
leftX  = xC - 200; 
rightX = xC + 200; 
yPos   = yC;

% ---------------- Trials ----------------------
for t = 1:nT
    lvl = order(t);
    testSpeed = P.refSpeed + P.speedDiffs(lvl);

    % run a single trial
    R = do_trial(win, [leftX rightX yPos], P, lvl, testSpeed, t, nT);

    % fill Trial index for logging convenience
    R.Trial = t;  %#ok<NASGU>  % (kept in the struct written below)

    % write per-trial CSV (unique filename using timestamp)
    ts = char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'));
    trialFile = fullfile(P.outDir, sprintf('%s_trial_%03d_%s.csv', P.participantID, t, ts));
    writetable(struct2table(R), trialFile);

    % stash for session outputs
    levelIdx(t)      = lvl;
    signedDiff(t)    = R.SignedDiff_rad_s;
    absDiff(t)       = abs(R.SignedDiff_rad_s);
    leftIsRef(t)     = R.LeftHasReference;
    speedLeftLog(t)  = R.SpeedLeft_rad_s;
    speedRightLog(t) = R.SpeedRight_rad_s;
    response(t)      = R.Response;
    rt(t)            = R.RT_s;
    correct(t)       = R.Correct;
end

% ---------------- Teardown & finalize ---------
Screen('CloseAll'); clear Screen;

finalize_session(levelIdx, signedDiff, absDiff, leftIsRef, ...
                 speedLeftLog, speedRightLog, response, rt, correct);

end

% =============== local cleanup helper =================
function cleanupPTB()
    % Ensures the display is restored even if an error occurs.
    Screen('CloseAll');
    clear Screen;
end
