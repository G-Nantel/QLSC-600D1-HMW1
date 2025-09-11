% Psychophysics mini‑assignment (MATLAB + Psychtoolbox)
% -----------------------------------------------------
% Two classic tasks you can run on classmates as participants.
% Requires Psychtoolbox‑3 (https://psychtoolbox.org/). Tested with MATLAB R2023+.
%
% Files in this canvas:
%  1) brightness_2AFC.m        — 2AFC brightness discrimination (estimates PSE & JND)
%  2) rt_simple.m              — Simple visual reaction time task (median RT)
%  3) analyze_brightness_2AFC.m— Quick analysis script for 2AFC CSVs (fits logistic)
%
% How to run:
%   • Open MATLAB → Set current folder to where you saved these files.
%   • Run: brightness_2AFC  (or)  rt_simple
%   • Data are saved as CSV next to the script.
%
% Notes:
%   • Response keys: LeftArrow (left brighter) / RightArrow (right brighter) for 2AFC.
%   • For RT task: press Space as fast as possible when the target appears.
%   • Escape key aborts safely.

%% =============================
%% 1) brightness_2AFC.m
%% =============================
% Save the remainder of this section into a file named brightness_2AFC.m

function brightness_2AFC

    % ---- Parameters ----
    pid        = input('Participant ID (e.g., P101): ','s');
    baseLum    = 0.5;  % base in [0,1]
    deltas     = [-0.12 -0.08 -0.04 -0.02 0 0.02 0.04 0.08 0.12]; % Right - Left
    reps       = 8;    % repeats per level (72 trials total)
    iti        = 0.4;  % inter‑trial interval (s)
    fixDur     = 0.4;  % fixation (s)
    rectSize   = [0 0 250 250];

    % ---- Build trial table ----
    nLevels = numel(deltas);
    order   = repmat(deltas, 1, reps);
    order   = order(randperm(numel(order)));
    nTrials = numel(order);

    % ---- Setup Psychtoolbox ----
    KbName('UnifyKeyNames');
    keyLeft  = KbName('LeftArrow');
    keyRight = KbName('RightArrow');
    keyEsc   = KbName('ESCAPE');

    ListenChar(2);
    oldVerb = Screen('Preference','Verbosity', 1);
    oldSkip = Screen('Preference','SkipSyncTests', 1);  % set to 0 in lab for accuracy

    try
        AssertOpenGL;
        screens = Screen('Screens');
        screenId = max(screens);
        [win, winRect] = Screen('OpenWindow', screenId, 0);
        Priority(MaxPriority(win));
        HideCursor(win);

        % Colors
        white = WhiteIndex(win);
        gray  = round(white * 0.5);
        Screen('FillRect', win, gray);
        Screen('Flip', win);

        % Precompute luminance (convert [0,1] → display range)
        clamp = @(x) max(0, min(1, x));
        % Stim locations (left & right centered vertically)
        [cx, cy] = RectCenter(winRect);
        leftPos  = CenterRectOnPoint(rectSize, cx - 300, cy);
        rightPos = CenterRectOnPoint(rectSize, cx + 300, cy);

        % Consent screen
        DrawFormattedText(win, ['Short perception study (\~5 min). Press SPACE to start.\n' ...
                                 'LeftArrow = left brighter, RightArrow = right brighter.\n' ...
                                 'Press ESC to quit at any time.'], 'center','center', white);
        Screen('Flip', win);
        KbStrokeWait;

        data = [];  % will collect rows: [trial, delta, leftLum, rightLum, choiceRight, correct, rt_ms]

        for t = 1:nTrials
            delta    = order(t);
            leftLum  = clamp(baseLum - delta/2);
            rightLum = clamp(baseLum + delta/2);

            % Convert to device color values
            leftColor  = round(white * leftLum);
            rightColor = round(white * rightLum);

            % ITI (blank gray)
            Screen('FillRect', win, gray);
            Screen('Flip', win);
            WaitSecs(iti);

            % Fixation
            drawFixation(win, cx, cy, white);
            Screen('Flip', win);
            WaitSecs(fixDur);

            % Draw stimuli until response
            t0 = Screen('Flip', win);  % time of last flip
            Screen('FillRect', win, gray);
            Screen('FillRect', win, leftColor,  leftPos);
            Screen('FillRect', win, rightColor, rightPos);
            vbl = Screen('Flip', win);

            % Collect response
            choiceRight = NaN; rt_ms = NaN; correct = NaN;
            while true
                [isDown, ~, keyCode] = KbCheck;
                if isDown
                    if keyCode(keyLeft)
                        choiceRight = 0; rt_ms = (GetSecs - vbl)*1000; break;
                    elseif keyCode(keyRight)
                        choiceRight = 1; rt_ms = (GetSecs - vbl)*1000; break;
                    elseif keyCode(keyEsc)
                        error('Aborted by user.');
                    end
                end
            end

            % correctness
            if rightLum > leftLum
                correct = choiceRight == 1;
            elseif leftLum > rightLum
                correct = choiceRight == 0;
            else
                correct = NaN; % equal
            end

            % store row
            data = [data; t, delta, leftLum, rightLum, choiceRight, correct, rt_ms]; %#ok<AGROW>
        end

        % Save CSV
        T = array2table(data, 'VariableNames', ...
            {'trial','delta','leftLum','rightLum','choiceRight','correct','rt_ms'});
        T.pid = repmat(string(pid), height(T), 1);
        T.ts  = repmat(string(datetime('now')), height(T), 1);
        T = movevars(T, {'pid','ts'}, 'Before', 'trial');
        fname = sprintf('%s_brightness_2AFC.csv', pid);
        writetable(T, fname);
        fprintf('Saved: %s\n', fname);

        % Quick end screen
        DrawFormattedText(win, 'Thanks! You are done.','center','center', white);
        Screen('Flip', win); WaitSecs(1);

        % Cleanup
        sca; ShowCursor; Priority(0);
        Screen('Preference','Verbosity', oldVerb);
        Screen('Preference','SkipSyncTests', oldSkip);
        ListenChar(0);

    catch ME
        sca; ShowCursor; Priority(0);
        Screen('Preference','Verbosity', oldVerb);
        Screen('Preference','SkipSyncTests', oldSkip);
        ListenChar(0);
        rethrow(ME);
    end
end

function drawFixation(win, cx, cy, color)
    Screen('FillRect', win, 0, []); % keep background as set by caller
    % actually draw fixation on top of current background
    Screen('DrawLine', win, color, cx-10, cy, cx+10, cy, 2);
    Screen('DrawLine', win, color, cx, cy-10, cx, cy+10, 2);
end


%% =============================
%% 2) rt_simple.m
%% =============================
% Save the remainder of this section into a file named rt_simple.m

function rt_simple
    pid       = input('Participant ID (e.g., P201): ','s');
    nTrials   = 25;
    foreMin   = 1.0;   % s
    foreMax   = 3.0;   % s
    deadline  = 1.5;   % s (responses later than this are flagged)

    KbName('UnifyKeyNames');
    keyGo   = KbName('SPACE');
    keyEsc  = KbName('ESCAPE');

    ListenChar(2);
    oldVerb = Screen('Preference','Verbosity', 1);
    oldSkip = Screen('Preference','SkipSyncTests', 1);

    try
        AssertOpenGL;
        [win, winRect] = Screen('OpenWindow', max(Screen('Screens')), 0);
        Priority(MaxPriority(win));
        HideCursor(win);
        white = WhiteIndex(win); gray = round(white*0.5);

        DrawFormattedText(win, ['Simple RT Task. Press SPACE when the target appears.\n' ...
                                 'Press SPACE to begin. ESC to quit.'], 'center','center', white);
        Screen('Flip', win); KbStrokeWait;

        rts = nan(nTrials,1);

        for t = 1:nTrials
            % ITI & fixation
            Screen('FillRect', win, gray);
            drawFixation(win, RectCenter(winRect));
            Screen('Flip', win); WaitSecs(0.5);

            % Foreperiod (blank gray)
            Screen('FillRect', win, gray);
            Screen('Flip', win);
            WaitSecs(foreMin + rand*(foreMax-foreMin));

            % Target (big white square)
            [cx, cy] = RectCenter(winRect);
            tgt = CenterRectOnPoint([0 0 200 200], cx, cy);
            Screen('FillRect', win, gray);
            Screen('FillRect', win, white, tgt);
            tOn = Screen('Flip', win);

            % Wait for SPACE
            rt_ms = NaN; tooSlow = false;
            while true
                [isDown, secs, keyCode] = KbCheck;
                if isDown
                    if keyCode(keyGo)
                        rt_ms = (secs - tOn)*1000; break;
                    elseif keyCode(keyEsc)
                        error('Aborted by user.');
                    end
                end
                if (GetSecs - tOn) > deadline
                    tooSlow = true; break;
                end
            end

            rts(t) = rt_ms;

            % Feedback
            Screen('FillRect', win, gray);
            if tooSlow
                DrawFormattedText(win, 'Too slow!', 'center', 'center', white);
            else
                DrawFormattedText(win, sprintf('RT = %.0f ms', rt_ms), 'center', 'center', white);
            end
            Screen('Flip', win); WaitSecs(0.5);
        end

        % Save CSV
        T = table((1:nTrials)', rts, 'VariableNames', {'trial','rt_ms'});
        T.pid = repmat(string(pid), height(T), 1);
        T.ts  = repmat(string(datetime('now')), height(T), 1);
        T = movevars(T, {'pid','ts'}, 'Before', 'trial');
        fname = sprintf('%s_RT.csv', pid);
        writetable(T, fname);
        fprintf('Saved: %s\n', fname);

        DrawFormattedText(win, 'Thanks! You are done.','center','center', white);
        Screen('Flip', win); WaitSecs(1);

        sca; ShowCursor; Priority(0);
        Screen('Preference','Verbosity', oldVerb);
        Screen('Preference','SkipSyncTests', oldSkip);
        ListenChar(0);

    catch ME
        sca; ShowCursor; Priority(0);
        Screen('Preference','Verbosity', oldVerb);
        Screen('Preference','SkipSyncTests', oldSkip);
        ListenChar(0);
        rethrow(ME);
    end
end

function drawFixation(win, center)
    white = WhiteIndex(win);
    cx = center(1); cy = center(2);
    Screen('DrawLine', win, white, cx-10, cy, cx+10, cy, 2);
    Screen('DrawLine', win, white, cx, cy-10, cx, cy+10, 2);
end


%% =====================================
%% 3) analyze_brightness_2AFC.m
%% =====================================
% Save the remainder of this section into a file named analyze_brightness_2AFC.m

function analyze_brightness_2AFC
    % Collect all *_brightness_2AFC.csv in the current folder
    files = dir('*_brightness_2AFC.csv');
    if isempty(files)
        error('No *_brightness_2AFC.csv files found.');
    end

    all = table();
    for k = 1:numel(files)
        T = readtable(fullfile(files(k).folder, files(k).name));
        all = [all; T]; %#ok<AGROW>
    end

    % Fit trial‑level logistic: P(choose right)=logit^{-1}(b0 + b1*delta)
    y = all.choiceRight; x = all.delta;
    [b,~,stats] = glmfit(x, y, 'binomial','link','logit');
    b0 = b(1); b1 = b(2);

    % Derived metrics
    pse = -b0/b1;                     % where P=0.5
    jnd = (log(3))/b1;                % (logit(.75)-logit(.25))/2 = ln(3)/b1

    fprintf('Group‑level PSE = %.3f, JND = %.3f\n', pse, jnd);

    % Plot
    figure; hold on;
    % empirical proportions per level
    G = groupsummary(all, 'delta', 'mean', 'choiceRight');
    scatter(G.delta, G.mean_choiceRight, 50, 'filled');
    % curve
    xs = linspace(min(x)-0.02, max(x)+0.02, 200); 
    ps = 1./(1+exp(-(b0 + b1*xs)));
    plot(xs, ps, 'LineWidth', 2);
    yline([0.25 0.5 0.75], ':'); xline([pse], '--');
    xlabel('Delta (Right - Left)'); ylabel('P(choose right)'); grid on;
    title(sprintf('Psychometric (PSE=%.3f, JND=%.3f)', pse, jnd));
end
