function R = do_trial(win, pos, P, levelIdx, testSpeed, trialNum, totalTrials)
% DO_TRIAL
% Runs ONE trial; participant can answer while spheres are spinning.
% Progress HUD shows "answered/total (percent)".
%
% Inputs:
%   win, pos, P, levelIdx, testSpeed  ... as before
%   trialNum      : current trial index (1-based)
%   totalTrials   : total number of trials in the session
%
% Output: struct with fields (ParticipantID, Trial, ConditionIndex, ...)

KbName('UnifyKeyNames');

% ----- unpack positions -----
leftX  = pos(1); rightX = pos(2); yPos = pos(3);

% ----- side assignment -----
if rand < 0.5
    speedLeft  = P.refSpeed;   speedRight = testSpeed;  leftIsRef = true;
else
    speedLeft  = testSpeed;    speedRight = P.refSpeed; leftIsRef = false;
end

% ----- fixation -----
fixCrossDimPix = 20; fixCrossLineW = 4;
fixCross = [-fixCrossDimPix +fixCrossDimPix 0 0; 0 0 -fixCrossDimPix +fixCrossDimPix];
Screen('FillRect', win, P.bgGray);
Screen('DrawLines', win, fixCross, fixCrossLineW, 0, [mean([leftX rightX]) yPos]);
Screen('Flip', win); WaitSecs(0.5);

% ----- ISI -----
Screen('FillRect', win, P.bgGray); Screen('Flip', win); WaitSecs(P.isiDuration);
KbReleaseWait;

% ----- key codes -----
key1   = unique([KbName('1!') KbName('1')]);
key2   = unique([KbName('2@') KbName('2')]);
keyEsc = KbName('ESCAPE');

% ----- progress string (answered so far) -----
showProgress = ~isfield(P,'showProgress') || P.showProgress;
progressStr = '';
if showProgress && nargin >= 7 && ~isempty(totalTrials) && totalTrials > 0
    answered = max(0, trialNum - 1);                     % completed BEFORE this trial
    pct = 100 * (answered / totalTrials);
    progressStr = sprintf('%d/%d (%.1f%% done)', answered, totalTrials, pct);
end

% ----- behavior: spin until response (default true) -----
spinUntilResp = ~isfield(P,'spinUntilResponse') || P.spinUntilResponse;
resp = 0; rt = NaN;

if spinUntilResp
    t0 = GetSecs;
    while true
        elapsed = GetSecs - t0;

        % safety timeout -> blocking prompt
        if isfield(P,'maxTrialSec') && elapsed > P.maxTrialSec
            DrawFormattedText(win, 'Time''s up - please answer.\n1 = Left, 2 = Right', ...
                              'center','center',0);
            if ~isempty(progressStr)
                DrawFormattedText(win, progressStr, 30, 30, 0);  % top-left
            end
            Screen('Flip', win);
            [rtAbs, keyCode] = KbWait;
            if keyCode(keyEsc), error('User aborted (ESC).'); end
            if any(keyCode(key1)), resp = 1; rt = rtAbs - t0; break; end
            if any(keyCode(key2)), resp = 2; rt = rtAbs - t0; break; end
            continue
        end

        % phases
        angL = mod(elapsed * speedLeft,  2*pi);
        angR = mod(elapsed * speedRight, 2*pi);

        % draw frame
        Screen('FillRect', win, P.bgGray);
        Screen('FrameOval', win, 0, CenterRectOnPointd([0 0 2*P.sphereRadius 2*P.sphereRadius], leftX,  yPos), 2);
        Screen('FrameOval', win, 0, CenterRectOnPointd([0 0 2*P.sphereRadius 2*P.sphereRadius], rightX, yPos), 2);
        drawSphereMeridians(win, leftX,  yPos, P.sphereRadius, P.nLines, angL, [0 0 0], 2, P.FRONT_CULL);
        drawSphereLatitudes(win, rightX, yPos, P.sphereRadius, P.nLines, angR, [0 0 0], 2, P.FRONT_CULL);

        % HUD
        if ~isfield(P,'showHUD') || P.showHUD
            DrawFormattedText(win, '1 = LEFT   2 = RIGHT   (ESC to quit)', ...
                              'center', yPos + P.sphereRadius + 40, 0);
        end
        if ~isempty(progressStr)
            DrawFormattedText(win, progressStr, 30, 30, 0);  % top-left
        end

        Screen('Flip', win);

        % keys
        [isDown, rtAbs, keyCode] = KbCheck;
        if ~isDown, continue; end
        if keyCode(keyEsc), error('User aborted (ESC).'); end
        if any(keyCode(key1)), resp = 1; rt = rtAbs - t0; break; end
        if any(keyCode(key2)), resp = 2; rt = rtAbs - t0; break; end
    end
else
    % fixed presentation, then prompt (fallback)
    t0 = GetSecs;
    while GetSecs - t0 < P.presentationDuration
        elapsed = GetSecs - t0;
        angL = mod(elapsed * speedLeft,  2*pi);
        angR = mod(elapsed * speedRight, 2*pi);
        [isDown, ~, keyCode] = KbCheck;
        if isDown && keyCode(keyEsc), error('User aborted (ESC).'); end
        Screen('FillRect', win, P.bgGray);
        Screen('FrameOval', win, 0, CenterRectOnPointd([0 0 2*P.sphereRadius 2*P.sphereRadius], leftX,  yPos), 2);
        Screen('FrameOval', win, 0, CenterRectOnPointd([0 0 2*P.sphereRadius 2*P.sphereRadius], rightX, yPos), 2);
        drawSphereMeridians(win, leftX,  yPos, P.sphereRadius, P.nLines, angL, [0 0 0], 2, P.FRONT_CULL);
        drawSphereLatitudes(win, rightX, yPos, P.sphereRadius, P.nLines, angR, [0 0 0], 2, P.FRONT_CULL);
        if ~isempty(progressStr), DrawFormattedText(win, progressStr, 30, 30, 0); end
        Screen('Flip', win);
    end
    DrawFormattedText(win, 'Which sphere is faster?  1 = Left,  2 = Right', 'center','center',0);
    if ~isempty(progressStr), DrawFormattedText(win, progressStr, 30, 30, 0); end
    Screen('Flip', win);
    rtStart = GetSecs;
    while resp == 0
        [rtAbs, keyCode] = KbWait; %#ok<ASGLU>
        if keyCode(keyEsc), error('User aborted (ESC).'); end
        if any(keyCode(key1)), resp = 1; rt = rtAbs - rtStart; end
        if any(keyCode(key2)), resp = 2; rt = rtAbs - rtStart; end
    end
end

% correctness
if     speedLeft  > speedRight, isCorrect = (resp == 1);
elseif speedRight > speedLeft,  isCorrect = (resp == 2);
else,  isCorrect = rand < 0.5;
end

% output struct
R = struct( ...
    'ParticipantID',        string(P.participantID), ...
    'Trial',                NaN, ...
    'ConditionIndex',       levelIdx, ...
    'ReferenceSpeed_rad_s', P.refSpeed, ...
    'SignedDiff_rad_s',     testSpeed - P.refSpeed, ...
    'LeftHasReference',     leftIsRef, ...
    'SpeedLeft_rad_s',      speedLeft, ...
    'SpeedRight_rad_s',     speedRight, ...
    'Response',             resp, ...
    'RT_s',                 rt, ...
    'Correct',              isCorrect, ...
    'Timestamp',            string(datetime('now','Format','yyyyMMdd_HHmmss_SSS')) ...
);
end
