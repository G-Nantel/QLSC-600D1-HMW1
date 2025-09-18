%
%PAL_AMPM_Override_Demo  Demonstrates how to override the intensity
%suggested by the psi(-marginal) method on any trial.
%
%This can be used for example to present a 'free' stimulus to prevent 
%observer frustration.
%
%More information on any of the functions may be found by typing
%help followed by the name of the function. e.g., help PAL_AMPM_setupPM
%
%NP (February 2023)

clear all

S = warning('QUERY', 'PALAMEDES:AMPM_setupPM:priorTranspose');
warning('off','PALAMEDES:AMPM_setupPM:priorTranspose');

%Set up psi
NumTrials = 240;

grain = 201; 

PF = @PAL_Gumbel; %assumed psychometric function

%Stimulus values the method can select from
stimRange = (linspace(PF([0 1 0 0],.1,'inverse'),PF([0 1 0 0],.9999,'inverse'),21));

%Define parameter ranges to be included in posterior
priorAlphaRange = linspace(PF([0 1 0 0],.1,'inverse'),PF([0 1 0 0],.9999,'inverse'),grain);
priorBetaRange =  linspace(log10(.0625),log10(16),grain); %Use log10 transformed values of beta (slope) parameter in PF
priorGammaRange = 0.5;  %fixed value (using vector here would make it a free parameter) 
priorLambdaRange = .02; %ditto

%Initialize PM structure
PM = PAL_AMPM_setupPM('priorAlphaRange',priorAlphaRange,...
                      'priorBetaRange',priorBetaRange,...
                      'priorGammaRange',priorGammaRange,...
                      'priorLambdaRange',priorLambdaRange,...
                      'numtrials',NumTrials,...
                      'PF' , PF,...
                      'stimRange',stimRange);                  

paramsGen = [0, 1, .5, .02];   %parameter values [alpha, beta, gamma, lambda] (or [threshold, slope, guess, lapse]) used to simulate observer
          
%trial loop
while PM.stop ~= 1

    %Roll ten-sided die to randomly decide whether we will override
    %proposed intensity and instead present an easy 'free trial'
    %(note that this decision strategy is not used here because we advise 
    %it, rather it is used because it is simple to implement and understand)
    if rand(1) < .1 %Make this a 'free' trial??
        freeTrial = 1;
        xIndex = length(PM.stimRange);   %force this stimulus intensity: PM.stimRange(end).
                                         %Note: xIndex is set to the index of the intensity to use, not the intensity itself
                                         %any of the entries in PM.stimRange may be used (i.e., xIndex may be any integer between 1 and length(PM.stimRange)
        xThatIsActuallyUsed = PM.stimRange(xIndex);
    else
        freeTrial = 0;
        xThatIsActuallyUsed = PM.xCurrent; %Use intensity suggested by method
    end

    response = rand(1) < PF(paramsGen, xThatIsActuallyUsed);    %simulate observer

    %update PM based on response
    if freeTrial
        PM = PAL_AMPM_updatePM(PM,response,'xIndex',xIndex);
    else
        PM = PAL_AMPM_updatePM(PM,response);
    end

end

disp('Threshold estimate:')
PM.threshold(end)
disp('Slope estimate:')
10.^PM.slope(end)           %PM.slope is in log10 units of beta parameter

%reset warning to original state
warning(S);