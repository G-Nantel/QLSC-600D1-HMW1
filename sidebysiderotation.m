clear all;
close all;
clc;

try
    % ---------- Settings ----------
    Screen('Preference', 'SkipSyncTests', 0);   % set to 1 for development only
    whichScreen = 0;
    bgGray = 128;
    winRect = [0 0 800 800];

    % Stimulus parameters
    sphereRadius = 100;                % px
    nLines = 12;                       % number of stripes
    presentationDuration = 1;          % seconds
    isiDuration = 0.5;                 % seconds
    refSpeed = pi;                     % rad/s
    speedDiffs = [-pi/2, -pi/4, 0, pi/4, pi/2];
    trialsPerLevel = 2;                % keep small while testing
    FRONT_CULL = true;                 % true = only draw front hemisphere

    % ---------- PTB Init ----------
    AssertOpenGL;
    [window, rect] = Screen('OpenWindow', whichScreen, bgGray, winRect);
    [~, ~] = Screen('WindowSize', window);
    [xCenter, yCenter] = RectCenter(rect);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Fixation cross geometry
    fixCrossDimPix = 20;
    fixCrossLineWidthPix = 4;
    fixCrossCoords = [-fixCrossDimPix fixCrossDimPix 0 0; 0 0 -fixCrossDimPix fixCrossDimPix];

    % ---------- Trial structure ----------
    nLevels = numel(speedDiffs);
    nTrials = nLevels * trialsPerLevel;
    trialOrder = repelem(1:nLevels, trialsPerLevel);
    trialOrder = trialOrder(randperm(nTrials));

    % Data storage
    responses     = zeros(nTrials,1);    % 1=Left, 2=Right
    actualDiffs   = zeros(nTrials,1);    % test - ref (per condition)
    responseTimes = zeros(nTrials,1);
    correct       = zeros(nTrials,1);

    % ---------- Instructions ----------
    instructText = ['Two spheres with curved stripes will rotate.\n' ...
        'Press ''1'' if the LEFT sphere is faster, ''2'' if the RIGHT sphere is faster.\n' ...
        'Press ESC at any time to quit.\n\nPress any key to start.'];
    DrawFormattedText(window, instructText, 'center', 'center', 0);
    Screen('Flip', window);
    KbWait;

    % ---------- Experiment loop ----------
    leftX  = xCenter - 200;
    rightX = xCenter + 200;
    yPos   = yCenter;

    for trial = 1:nTrials
        % Determine trial speeds
        level = trialOrder(trial);
        testSpeed = refSpeed + speedDiffs(level);
        actualDiffs(trial) = speedDiffs(level);

        % Randomize which side gets the reference/test speeds
        if rand < 0.5
            speedLeftSphere  = refSpeed;
            speedRightSphere = testSpeed;
        else
            speedLeftSphere  = testSpeed;
            speedRightSphere = refSpeed;
        end

        % Fixation
        Screen('FillRect', window, bgGray);
        Screen('DrawLines', window, fixCrossCoords, fixCrossLineWidthPix, 0, [xCenter yCenter]);
        Screen('Flip', window);
        WaitSecs(0.5);

        % ISI (blank)
        Screen('FillRect', window, bgGray);
        Screen('Flip', window);
        WaitSecs(isiDuration);

        % Present spheres
        startTime = GetSecs;
        while GetSecs - startTime < presentationDuration
            elapsed = GetSecs - startTime;
            angleLeft  = mod(elapsed * speedLeftSphere,  2*pi);
            angleRight = mod(elapsed * speedRightSphere, 2*pi);

            % Check for escape (KbCheck returns keyIsDown, secs, keyCode)
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && keyCode(KbName('ESCAPE'))
                Screen('CloseAll'); clear Screen; return;
            end

            % Draw frame
            Screen('FillRect', window, bgGray);

            % Left sphere outline
            Screen('FrameOval', window, 0, CenterRectOnPointd([0 0 2*sphereRadius 2*sphereRadius], leftX,  yPos), 2);
            % Right sphere outline
            Screen('FrameOval', window, 0, CenterRectOnPointd([0 0 2*sphereRadius 2*sphereRadius], rightX, yPos), 2);

            % Left: vertical curved lines (meridians)
            drawSphereMeridians(window, leftX, yPos, sphereRadius, nLines, angleLeft, [0 0 0], 2, FRONT_CULL);

            % Right: horizontal curved lines (latitudes)
            drawSphereLatitudes(window, rightX, yPos, sphereRadius, nLines, angleRight, [0 0 0], 2, FRONT_CULL);

            Screen('Flip', window);
        end

        % Response prompt
        DrawFormattedText(window, 'Which sphere is faster?  1 = Left,  2 = Right', 'center', 'center', 0);
        Screen('Flip', window);
        responseStartTime = GetSecs;

        % Collect response (KbWait returns [secs, keyCode, deltaSecs])
        resp = 0; secs = responseStartTime;
        while resp == 0
            [secs, keyCode] = KbWait;  % <-- correct order
            if keyCode(KbName('ESCAPE'))
                Screen('CloseAll'); clear Screen; return;
            elseif any(keyCode([KbName('1!'), KbName('1')]))
                resp = 1;
            elseif any(keyCode([KbName('2@'), KbName('2')]))
                resp = 2;
            end
        end

        responses(trial) = resp;
        responseTimes(trial) = secs - responseStartTime;

        % Correctness bookkeeping (ties counted as random)
        if speedLeftSphere > speedRightSphere
            correct(trial) = (resp == 1);
        elseif speedRightSphere > speedLeftSphere
            correct(trial) = (resp == 2);
        else
            correct(trial) = rand < 0.5;
        end
    end

    % ---------- Clean up visual ----------
    Screen('CloseAll');
    clear Screen;

    % ---------- Analyze & Plot ----------
    uniqueDiffs = unique(speedDiffs);
    propRightFaster = zeros(size(uniqueDiffs));
    for i = 1:length(uniqueDiffs)
        idx = (actualDiffs == uniqueDiffs(i));   % correct indexing
        propRightFaster(i) = mean(responses(idx) == 2);
    end

    figure;
    plot(uniqueDiffs / pi, propRightFaster, 'o-', 'LineWidth', 2);
    xlabel('Speed Difference (multiples of \pi rad/s)');
    ylabel('Proportion "Right Faster"');
    title('Psychometric Function for Speed Discrimination');
    grid on;

    % ---------- Save data ----------
    dataTable = table(actualDiffs, responses, responseTimes, correct, ...
        'VariableNames', {'SpeedDifference_rad_s','Response','ResponseTime_s','Correct'});
    writetable(dataTable, 'speed_discrimination_results.csv');
    save('speed_discrimination_data.mat', 'responses','actualDiffs','responseTimes','correct');

    disp('Experiment completed. Psychometric function plotted and data saved.');

catch ME
    Screen('CloseAll'); clear Screen;
    rethrow(ME);
end

% ==============================================================
% =============== Helper drawing functions =====================
% ==============================================================

function drawSphereMeridians(window, cx, cy, R, nLines, angle, color, lineW, frontCull)
% Draw vertical "curved lines" (meridians) on a sphere rotating about the vertical axis.
% Parametrization (unit sphere):
% x =  sin(t)cos(phi)
% y =  cos(t)
% z =  sin(t)sin(phi)
% Project (x, y) to screen (cx + R*x, cy - R*y). Cull where z<0 if frontCull.
    t = linspace(0, pi, 400);  % full diameter
    for k = 1:nLines
        phi = 2*pi*k/nLines + angle;
        x = R * sin(t) .* cos(phi);
        y = R * cos(t);
        z = R * sin(t) .* sin(phi);

        if frontCull
            keep = (z >= 0);
            x = x(keep);
            y = y(keep);
        end

        xCurve = cx + x;
        yCurve = cy - y;
        if ~isempty(xCurve)
            Screen('DrawLines', window, [xCurve; yCurve], lineW, color);
        end
    end
end

function drawSphereLatitudes(window, cx, cy, R, nLines, angle, color, lineW, frontCull)
% Draw horizontal "curved lines" (latitudes) on a sphere rotating about the vertical axis.
% Parametrization (unit sphere) rotated so stripes look horizontal:
% x =  cos(t)
% y =  sin(t)cos(phi)
% z =  sin(t)sin(phi)
% Project (x, y) to screen (cx + R*x, cy - R*y). Cull where z<0 if frontCull.
    t = linspace(0, pi, 400);  % full diameter
    for k = 1:nLines
        phi = 2*pi*k/nLines + angle;
        x = R * cos(t);
        y = R * sin(t) .* cos(phi);
        z = R * sin(t) .* sin(phi);

        if frontCull
            keep = (z >= 0);
            x = x(keep);
            y = y(keep);
        end

        xCurve = cx + x;
        yCurve = cy - y;
        if ~isempty(xCurve)
            Screen('DrawLines', window, [xCurve; yCurve], lineW, color);
        end
    end
end
