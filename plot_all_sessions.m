function plot_all_sessions(resultsDir, visualsDir)
if nargin < 1 || isempty(resultsDir), resultsDir = 'test_run_trials'; end
if nargin < 2 || isempty(visualsDir), visualsDir = 'visuals'; end
if ~exist(visualsDir,'dir'), mkdir(visualsDir); end

files = dir(fullfile(resultsDir, '*_session_*.csv'));
if isempty(files)
    warning('No session CSVs found in %s', resultsDir);
    return;
end

fig = figure('Color','w'); hold on;
for k = 1:numel(files)
    T = readtable(fullfile(resultsDir, files(k).name));
    % Ensure required variables exist
    if ~ismember('AbsDiff_rad_s', T.Properties.VariableNames)
        if ismember('SignedDiff_rad_s', T.Properties.VariableNames)
            T.AbsDiff_rad_s = abs(T.SignedDiff_rad_s);
        else
            warning('Skipping %s (missing AbsDiff/SignedDiff)', files(k).name);
            continue;
        end
    end
    if ~ismember('Correct', T.Properties.VariableNames)
        warning('Skipping %s (missing Correct column)', files(k).name);
        continue;
    end

    uAbs = unique(T.AbsDiff_rad_s);
    pc   = zeros(size(uAbs));
    for i = 1:numel(uAbs)
        idx = (T.AbsDiff_rad_s == uAbs(i));
        pc(i) = mean(T.Correct(idx));
    end
    [uAbs, order] = sort(uAbs);
    pc = pc(order);

    plot(uAbs/pi, pc, 'o-', 'LineWidth', 1.5, 'DisplayName', files(k).name);
end

xlabel('|\Delta speed| (multiples of \pi rad/s)');
ylabel('Proportion correct');
title('All sessions — proportion correct vs |\Delta|');
grid on; legend('Interpreter','none','Location','SouthEast');

outPNG = fullfile(visualsDir, 'all_sessions_overlaid.png');
try
    exportgraphics(fig, outPNG, 'Resolution', 150);
catch
    saveas(fig, outPNG);
end
disp(['Saved overlay: ', outPNG]);
end
