% Psychophysics Experiment: Speed Discrimination with Meshgrid and Psychtoolbox
% This script implements a 2IFC task to discriminate rotational speed of a dot.
% Uses meshgrid to create a circular mask for the stimulus.
%
% Requirements:
% - MATLAB
% - Psychophysics Toolbox (PTB) installed[](http://psychtoolbox.org/)
%
% Experiment Structure:
% - Fixation cross (500 ms)
% - First interval: Rotating dot within a circular mask (1 second)
% - ISI: 1 second blank
% - Second interval: Rotating dot at different speed (1 second)
% - Response: '1' if first was faster, '2' if second was faster
% - Psychometric function plotted at the end

% Clear workspace and screen
clear all;
close all;
clc;

try
    % Initialize Psychtoolbox
    Screen('Preference', 'SkipSyncTests', 0); % Ensure maximum timing accuracy
    whichScreen = 0;
    [window, rect] = Screen('OpenWindow', whichScreen, 128, [0 0 800 800]); % Grey background, 800x800 window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    [xCenter, yCenter] = RectCenter(rect);

    % Set up blending for smooth drawing
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Fixation cross parameters
    fixCrossDimPix = 20;
    fixCrossLineWidthPix = 4;
    fixCrossCoords = [-fixCrossDimPix fixCrossDimPix 0 0; 0 0 -fixCrossDimPix fixCrossDimPix];

    % Stimulus parameters
    circleRadius = 100; % Radius of the circular mask in pixels
    dotRadius = 10; % Radius of the rotating dot
    presentationDuration = 1; % Duration of each stimulus in seconds
    isiDuration = 1; % Inter-stimulus interval in seconds

    % Create circular mask using meshgrid
    gridSize = 2 * circleRadius; % Size of the texture
    x = -circleRadius:circleRadius;
    y = -circleRadius:circleRadius;
    [X, Y] = meshgrid(x, y);
    % Create a circular mask (1 inside circle, 0 outside, with alpha for smooth edges)
    mask = sqrt(X.^2 + Y.^2) <= circleRadius;
    mask = double(mask); % Convert to double for texture
    % Add smooth edge
    edgeWidth = 5; % Pixels for smooth transition
    dist = sqrt(X.^2 + Y.^2);
    mask(dist > circleRadius - edgeWidth & dist <= circleRadius) = ...
        1 - (dist(dist > circleRadius - edgeWidth & dist <= circleRadius) - (circleRadius - edgeWidth)) / edgeWidth;

    % Reference speed (radians per second)
    refSpeed = 2 * pi; % One full rotation per second

    % Test speed differences (relative to reference, in rad/s)
    speedDiffs = [-pi, -pi/2, -pi/4, 0, pi/4, pi/2, pi]; % Test speed variations
    nLevels = length(speedDiffs);
    nTrialsPerLevel = 10; % Trials per speed difference
    nTrials = nLevels * nTrialsPerLevel;

    % Randomize trial order
    trialOrder = repmat(1:nLevels, 1, nTrialsPerLevel);
    trialOrder = trialOrder(randperm(nTrials));

    % Data storage
    responses = zeros(nTrials, 1); % 1 = first faster, 2 = second faster
    actualDiffs = zeros(nTrials, 1); % Speed differences

    % Instructions
    instructText = 'You will see two rotating dots.\nPress ''1'' if the first was faster, ''2'' if the second was faster.\nPress any key to start.';
    DrawFormattedText(window, instructText, 'center', 'center', 0);
    Screen('Flip', window);
    KbWait;

    % Main experiment loop
    for trial = 1:nTrials
        % Determine speeds for this trial
        level = trialOrder(trial);
        testSpeed = refSpeed + speedDiffs(level);
        actualDiffs(trial) = speedDiffs(level);

        % Randomize which interval is reference
        if rand < 0.5
            speed1 = refSpeed;
            speed2 = testSpeed;
        else
            speed1 = testSpeed;
            speed2 = refSpeed;
        end

        % Fixation cross
        Screen('DrawLines', window, fixCrossCoords, fixCrossLineWidthPix, 0, [xCenter yCenter]);
        Screen('Flip', window);
        WaitSecs(0.5);

        % Blank screen before first stimulus
        Screen('Flip', window);
        WaitSecs(0.2);

        % Present first stimulus (rotating dot)
        startTime = GetSecs;
        while GetSecs - startTime < presentationDuration
            % Calculate dot position
            angle = mod((GetSecs - startTime) * speed1, 2*pi);
            % Create texture for the dot
            dotTexture = ones(gridSize+1, gridSize+1, 4) * 128; % Grey background with alpha
            dotTexture(:, :, 1:3) = 128; % Grey RGB
            dotTexture(:, :, 4) = mask * 255; % Apply circular mask to alpha channel
            % Draw black dot at current angle
            dotX = round(gridSize/2 + circleRadius * 0.8 * cos(angle)); % Dot at 80% radius
            dotY = round(gridSize/2 - circleRadius * 0.8 * sin(angle)); % Negative for clockwise
            dotMask = sqrt((X - (dotX - gridSize/2)).^2 + (Y - (dotY - gridSize/2)).^2) <= dotRadius;
            dotTexture(repmat(dotMask, [1 1 3])) = 0; % Set dot to black
            tex1 = Screen('MakeTexture', window, dotTexture);

            % Draw texture
            destRect = CenterRectOnPointd([0 0 gridSize gridSize], xCenter, yCenter);
            Screen('DrawTexture', window, tex1, [], destRect, [], [], 1);
            Screen('Flip', window);
            Screen('Close', tex1); % Clean up texture
        end

        % ISI (blank)
        Screen('Flip', window);
        WaitSecs(isiDuration);

        % Present second stimulus
        startTime = GetSecs;
        while GetSecs - startTime < presentationDuration
            angle = mod((GetSecs - startTime) * speed2, 2*pi);
            dotTexture = ones(gridSize+1, gridSize+1, 4) * 128;
            dotTexture(:, :, 1:3) = 128;
            dotTexture(:, :, 4) = mask * 255;
            dotX = round(gridSize/2 + circleRadius * 0.8 * cos(angle));
            dotY = round(gridSize/2 - circleRadius * 0.8 * sin(angle));
            dotMask = sqrt((X - (dotX - gridSize/2)).^2 + (Y - (dotY - gridSize/2)).^2) <= dotRadius;
            dotTexture(repmat(dotMask, [1 1 3])) = 0;
            tex2 = Screen('MakeTexture', window, dotTexture);

            destRect = CenterRectOnPointd([0 0 gridSize gridSize], xCenter, yCenter);
            Screen('DrawTexture', window, tex2, [], destRect, [], [], 1);
            Screen('Flip', window);
            Screen('Close', tex2);
        end

        % Response prompt
        Screen('Flip', window);
        DrawFormattedText(window, 'Which was faster? 1 or 2', 'center', 'center', 0);
        Screen('Flip', window);

        % Wait for response
        resp = 0;
        while resp == 0
            [~, keyCode] = KbWait;
            if find(keyCode) == KbName('1!')
                resp = 1;
            elseif find(keyCode) == KbName('2@')
                resp = 2;
            end
        end
        responses(trial) = resp;
    end

    % Clean up
    Screen('CloseAll');
    clear Screen;

    % Analyze data for psychometric function
    uniqueDiffs = unique(speedDiffs);
    propSecondFaster = zeros(size(uniqueDiffs));
    for i = 1:length(uniqueDiffs)
        idx = actualDiffs == uniqueDiffs(i);
        propSecondFaster(i) = mean(responses(idx) == 2);
    end

    % Plot psychometric function
    figure;
    plot(uniqueDiffs / pi, propSecondFaster, 'o-', 'LineWidth', 2);
    xlabel('Speed Difference (multiples of \pi rad/s)');
    ylabel('Proportion "Second Faster"');
    title('Psychometric Function for Speed Discrimination');
    grid on;

    % Save data
    save('speed_discrimination_data.mat', 'responses', 'actualDiffs');

    % Explanation of Psychometric Function
    disp('The plot shows the proportion of trials where the second stimulus was judged faster.');
    disp('X-axis: Speed difference (test - reference). Negative means test is slower.');
    disp('Y-axis: Proportion of "second faster" responses.');
    disp('At zero difference, expect ~0.5 (chance). A sigmoid fit can estimate threshold.');

catch
    % Error handling
    Screen('CloseAll');
    clear Screen;
    rethrow(lasterror);
end