function finalize_session(levelIdx, signedDiff, absDiff, leftIsRef, ...
                          speedLeftLog, speedRightLog, response, rt, correct)
% Creates the unsigned PF plot (proportion correct vs |Δ|),
% writes one session-level CSV, and a MAT with all variables.

% ----- unsigned PF (sensitivity/JND view) -----
uAbs = unique(absDiff);
pc   = zeros(size(uAbs));
n    = zeros(size(uAbs));
for i = 1:numel(uAbs)
    idx = (absDiff == uAbs(i));
    pc(i) = mean(correct(idx));
    n(i)  = sum(idx);
end

figure;
plot(uAbs / pi, pc, 'o-', 'LineWidth', 2);
xlabel('|\Delta speed| (multiples of \pi rad/s)');
ylabel('Proportion correct');
title('Speed discrimination (unsigned) — sensitivity/JND view');
grid on;

% ----- session CSV -----
T = table(levelIdx, signedDiff, absDiff, leftIsRef, speedLeftLog, speedRightLog, ...
          response, rt, correct, ...
          'VariableNames', {'ConditionIndex','SignedDiff_rad_s','AbsDiff_rad_s','LeftHasReference', ...
                            'SpeedLeft_rad_s','SpeedRight_rad_s','Response','RT_s','Correct'});
writetable(T, 'speed_discrimination_results.csv');

% ----- session MAT -----
save('speed_discrimination_data.mat', 'levelIdx','signedDiff','absDiff', ...
     'leftIsRef','speedLeftLog','speedRightLog','response','rt','correct');

disp('Saved: plot, session CSV, and MAT.');
end
