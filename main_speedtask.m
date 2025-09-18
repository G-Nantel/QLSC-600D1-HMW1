function main_speedtask
rng('shuffle');
P = config_speedtask();

AssertOpenGL; KbName('UnifyKeyNames');
[win, rect] = Screen('OpenWindow', P.whichScreen, P.bgGray, P.winRect);
cleanupObj = onCleanup(@() cleanupPTB()); %#ok<NASGU>

[xC, yC] = RectCenter(rect);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Ensure folders exist
if ~exist(P.resultsDir,'dir'), mkdir(P.resultsDir); end
if ~exist(P.visualsDir,'dir'), mkdir(P.visualsDir); end
if isfield(P,'writePerTrialCSV') && P.writePerTrialCSV
    if ~exist(P.outDir,'dir'), mkdir(P.outDir); end
end

% Instructions
DrawFormattedText(win, ['Two spheres rotate.\n' ...
    '1 = LEFT faster,  2 = RIGHT faster.\nESC to quit.\n\nPress any key to start.'], ...
    'center','center',0);
Screen('Flip', win); KbWait;

% Trial order (supports repeatsPerLevel OR trialsPerLevel)
nLevels = numel(P.speedDiffs);
if isfield(P,'repeatsPerLevel')
    assert(numel(P.repeatsPerLevel)==nLevels, 'repeatsPerLevel size mismatch');
    order = [];
    for lvl = 1:nLevels, order = [order, repmat(lvl, 1, P.repeatsPerLevel(lvl))]; end %#ok<AGROW>
elseif isfield(P,'trialsPerLevel')
    order = repelem(1:nLevels, P.trialsPerLevel);
else
    error('Provide P.repeatsPerLevel or P.trialsPerLevel in config_speedtask.m');
end
order = order(randperm(numel(order)));
nT    = numel(order);

% Session buffers
levelIdx      = zeros(nT,1);
signedDiff    = zeros(nT,1);
absDiff       = zeros(nT,1);
leftIsRef     = false(nT,1);
speedLeftLog  = zeros(nT,1);
speedRightLog = zeros(nT,1);
response      = zeros(nT,1);
rt            = zeros(nT,1);
correct       = zeros(nT,1);

% Positions
leftX = xC - 200; rightX = xC + 200; yPos = yC;

% Trials
for t = 1:nT
    lvl = order(t);
    testSpeed = P.refSpeed + P.speedDiffs(lvl);

    R = do_trial(win, [leftX rightX yPos], P, lvl, testSpeed, t, nT);

    % Optional per-trial CSVs
    if isfield(P,'writePerTrialCSV') && P.writePerTrialCSV
        ts = char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'));
        trialFile = fullfile(P.outDir, sprintf('%s_trial_%03d_%s.csv', P.participantID, t, ts));
        writetable(struct2table(R), trialFile);
    end

    % Stash for session outputs
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

Screen('CloseAll'); clear Screen;

% Unique session names & paths
stamp       = char(datetime('now','Format','yyyyMMdd_HHmmss'));
sessionBase = sprintf('%s_session_%s', P.participantID, stamp);
sessionCSV  = fullfile(P.resultsDir, [sessionBase '.csv']);
sessionPNG  = fullfile(P.visualsDir, [sessionBase '.png']);

% Save CSV/MAT and per-run figure into those folders
finalize_session(levelIdx, signedDiff, absDiff, leftIsRef, ...
                 speedLeftLog, speedRightLog, response, rt, correct, ...
                 sessionCSV, sessionPNG);

% (Optional) also refresh an overlay of ALL sessions' curves
% plot_all_sessions(P.resultsDir, P.visualsDir);
end

function cleanupPTB()
    Screen('CloseAll'); clear Screen;
end
