
%%

 datestr(clock,'yyyy-mm-dd-THHMM')
 
 
 %%
searchGrid=[];
searchGrid.alpha = 4;
searchGrid.beta = .1:.1:5;
searchGrid.gamma = 0.5;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0;  %ditto

PF = @PAL_Weibull;
    %Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter

StimLevels=([1 2 4 8 16 32 64]);
NumPos =[15 16 20  25 29 30 30] ;
OutOfNum=[10 10 10 10 10 10 10]*3;

StimLevels=([1 2 4 8 16 32 64]);
NumPos =[0 3 5  22 27 9 2] ;
OutOfNum=[1 5 10 30 30 10 2];

disp('Fitting function.....');
[paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels,NumPos,  OutOfNum,searchGrid,paramsFree,PF);
paramsValues

%
figure; hold 
plot(StimLevels,NumPos./OutOfNum,'+')

dispvect=.01:.001:100;
plot(dispvect,PF(paramsValues,dispvect))
%
set(gca,'Xscale', 'log')
 xlim([.01 100])


    
    