% Psychophysics Experiment: Speed Discrimination with Circle Outline and Moving Dot
% 2IFC task with one circle at a time, showing a circle outline and a dot moving around it.
% Tracks response time and correctness, 14 trials total (2 per speed difference).
%
% Requirements:
% - MATLAB
% - Psychophysics Toolbox (PTB) installed[](http://psychtoolbox.org/)
%
% Experiment Structure:
% - Fixation cross (500 ms)
% - First interval: Circle outline with moving dot (1 second)
% - ISI: 1 second blank
% - Second interval: Circle outline with moving dot at different speed (1 second)
% - Response: '1' if first was faster, '2' if second was faster
% - Psychometric function plotted at the end

% Clear workspace and screen
clear all;
close all;
clc;

try
    % Initialize Psychtoolbox
    Screen('Preference', 'SkipSyncTests', 0);
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
    circleRadius = 100; % Radius of the circle outline in pixels
    dotRadius = 10; % Radius of the moving dot
    presentationDuration = 1; % Duration of each stimulus in seconds
    isiDuration = 1; % Inter-stimulus interval in seconds

    % Reference speed (radians per second)
    refSpeed = 2 * pi; % One full rotation per second

    % Test speed differences (relative to reference, in rad/s)
    speedDiffs = [-pi, -pi/2, -pi/4, 0, pi/4, pi/2, pi];
    nLevels = length(speedDiffs);
    nTrials = 14; % Total of 14 trials (2 per level)

    % Distribute 14 trials across levels
    trialsPerLevel = [2, 2, 2, 2, 2, 2, 2]; % 2 trials per speed difference
    trialOrder = [];
    for i = 1:nLevels
        trialOrder = [trialOrder, repmat(i, 1, trialsPerLevel(i))];
    end
    trialOrder = trialOrder(randperm(nTrials)); % Randomize order

    % Data storage
    responses = zeros(nTrials, 1); % 1 = first faster, 2 = second faster
    actualDiffs = zeros(nTrials, 1); % Speed differences
    responseTimes = zeros(nTrials, 1); % Time to respond in seconds
    correct = zeros(nTrials, 1); % 1 = correct, 0 = incorrect

    % Instructions
    instructText = 'You will see a circle outline with a dot moving around it.\nPress ''1'' if the first was faster, ''2'' if the second was faster.\nPress any key to start.';
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

        % Present first stimulus (circle outline with moving dot)
        startTime = GetSecs;
        while GetSecs - startTime < presentationDuration
            angle = mod((GetSecs - startTime) * speed1, 2*pi);
            dotX = xCenter + (circleRadius - dotRadius) * cos(angle); % Move inside outline
            dotY = yCenter - (circleRadius - dotRadius) * sin(angle); % Negative for clockwise

            % Draw circle outline
            Screen('FrameOval', window, 0, CenterRectOnPointd([0 0 2*circleRadius 2*circleRadius], xCenter, yCenter), 2);

            % Draw moving dot
            Screen('FillOval', window, 0, CenterRectOnPointd([0 0 2*dotRadius 2*dotRadius], dotX, dotY));

            Screen('Flip', window);
        end

        % ISI (blank)
        Screen('Flip', window);
        WaitSecs(isiDuration);

        % Present second stimulus
        startTime = GetSecs;
        while GetSecs - startTime < presentationDuration
            angle = mod((GetSecs - startTime) * speed2, 2*pi);
            dotX = xCenter + (circleRadius - dotRadius) * cos(angle);
            dotY = yCenter - (circleRadius - dotRadius) * sin(angle);

            Screen('FrameOval', window, 0, CenterRectOnPointd([0 0 2*circleRadius 2*circleRadius], xCenter, yCenter), 2);
            Screen('FillOval', window, 0, CenterRectOnPointd([0 0 2*dotRadius 2*dotRadius], dotX, dotY));

            Screen('Flip', window);
        end

        % Response prompt
        Screen('Flip', window);
        DrawFormattedText(window, 'Which was faster? 1 or 2', 'center', 'center', 0);
        Screen('Flip', window);
        responseStartTime = GetSecs; % Start timing response

        % Wait for response
        resp = 0;
        while resp == 0
            [secs, keyCode] = KbWait;
            if find(keyCode) == KbName('1!')
                resp = 1;
            elseif find(keyCode) == KbName('2@')
                resp = 2;
            end
        end
        responses(trial) = resp;
        responseTimes(trial) = secs - responseStartTime; % Record response time

        % Determine if correct
        if speed1 > speed2
            correct(trial) = (resp == 1); % First was faster, should choose 1
        elseif speed2 > speed1
            correct(trial) = (resp == 2); % Second was faster, should choose 2
        else
            correct(trial) = rand < 0.5; % Equal speeds, chance correctness
        end
    end

    % Clean up
    Screen('CloseAll');
    clear Screen;

    % Analyze data for psychometric function
    uniqueDiffs = unique(speedDiffs);
    propSecondFaster = zeros(size(uniqueDiffs));
    for i = 1:length(uniqueDiffs)
        idx = actualDiffs == speedDiffs(i);
        propSecondFaster(i) = mean(responses(idx) == 2);
    end

    % Plot psychometric function
    figure;
    plot(uniqueDiffs / pi, propSecondFaster, 'o-', 'LineWidth', 2);
    xlabel('Speed Difference (multiples of \pi rad/s)');
    ylabel('Proportion "Second Faster"');
    title('Psychometric Function for Speed Discrimination');
    grid on;

    % Save data to CSV
    dataTable = table(actualDiffs, responses, responseTimes, correct, ...
        'VariableNames', {'SpeedDifference_rad_s', 'Response', 'ResponseTime_s', 'Correct'});
    writetable(dataTable, 'speed_discrimination_results.csv');

    % Save data to .mat file (optional)
    save('speed_discrimination_data.mat', 'responses', 'actualDiffs', 'responseTimes', 'correct');

    % Explanation of Psychometric Function
    disp('The plot shows the proportion of trials where the second stimulus was judged faster.');
    disp('X-axis: Speed difference (test - reference). Negative means test is slower.');
    disp('Y-axis: Proportion of "second faster" responses.');
    disp('At zero difference, expect ~0.5 (chance). With 14 trials, the curve should be less noisy.');

catch
    % Error handling
    Screen('CloseAll');
    clear Screen;
    rethrow(lasterror);
end