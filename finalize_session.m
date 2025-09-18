function finalize_session(levelIdx, signedDiff, absDiff, leftIsRef, ...
                          speedLeftLog, speedRightLog, response, rt, correct, ...
                          outCSV, outFigPNG)

if nargin < 10 || isempty(outCSV),   outCSV   = 'speed_discrimination_results.csv'; end
if nargin < 11,                      outFigPNG = ''; end
outMAT = regexprep(outCSV, '\.csv$', '.mat');

% ----- unsigned PF -----
uAbs = unique(absDiff);
pc   = zeros(size(uAbs));
n    = zeros(size(uAbs));
for i = 1:numel(uAbs)
    idx = (absDiff == uAbs(i));
    pc(i) = mean(correct(idx));
    n(i)  = sum(idx);
end

fig = figure('Color','w');
plot(uAbs/pi, pc, 'o-', 'LineWidth', 2);
xlabel('|\Delta speed| (multiples of \pi rad/s)');
ylabel('Proportion correct');
title('Speed discrimination (unsigned) — sensitivity/JND view');
grid on;

if ~isempty(outFigPNG)
    try
        exportgraphics(fig, outFigPNG, 'Resolution', 150);
    catch
        saveas(fig, outFigPNG);  % fallback
    end
end

% ----- session CSV & MAT -----
T = table(levelIdx, signedDiff, absDiff, leftIsRef, speedLeftLog, speedRightLog, ...
          response, rt, correct, ...
          'VariableNames', {'ConditionIndex','SignedDiff_rad_s','AbsDiff_rad_s','LeftHasReference', ...
                            'SpeedLeft_rad_s','SpeedRight_rad_s','Response','RT_s','Correct'});
writetable(T, outCSV);
save(outMAT, 'levelIdx','signedDiff','absDiff','leftIsRef','speedLeftLog','speedRightLog','response','rt','correct');

disp(['Saved: ', outCSV]);
if ~isempty(outFigPNG), disp(['Saved: ', outFigPNG]); end
end
