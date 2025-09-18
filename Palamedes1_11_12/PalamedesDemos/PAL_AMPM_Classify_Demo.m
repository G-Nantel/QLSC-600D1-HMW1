%
%PAL_AMPM_Classify_Demo  Demonstrates use of Palamedes AMPM routines to 
%optimize the classification of an observer into one of multiple distinct
% and individually diverse populations. It is an extension of the
% psi-method by Kontsevich and Tyler (1999). The original psi-method
% optimized the location ('threshold') and slope of the psychometric
% function (PF). The implementation in Palamedes allows optimization of any 
% combination of the parameters of the PF (location, slope, guess rate, and
% lapse rate) and also allows the inclusion of a fifth, discrete category
% parameter in the posterior. This allows the specification of multiple 
% distinct populations of observers that differ with respect to their 
% distributions of parameter values (e.g., 'normals' vs pathological
% observers). Any combination of parameters can be designated to be 
% of primary interest (whose estimation should be optimized), or treated as
% nuisance parameters (method will include these parameters in posterior
% but will not attempt to optimize these per se) or as fixed parameters
% (for more information on this see Prins, 2013).
%
% In this example, two populations are defined which differ with respect to 
% location and slope of the PF. The two populations are displayed as
% surfaces in location x slope space (top right figure) and as PFs with
% 68% and 95% high-density regions in the bottom figure (note that here the
% high density regions merely indicate the prevalence in the populations,
% not ensuing estimation accuracy). In this example, the method treats 
% location, slope and category/population as free parameters and guess rate 
% and lapse rate as fixed parameters. The user is prompted to either 
% optimize estimation of all parameters or to optimize only with respect to 
% category membership. The latter option will generally lead to improved 
% categorization performance (fewer trials needed to reach any desired 
% categorization confidence level) at the cost of less precision in the 
% estimates of location and slope values.
%
% Note that many more possibilities exist! (e.g., optimize with respect to
% category membership and location parameter, with slope and lapse rate 
% allowed to vary but not optimized and guess rate fixed).
%
% For more information, see Prins (2022)
%
%References:
%
%Kontsevich, LL & Tyler, CW (1999). Bayesian adaptive estimation of
%psychometric slope and threshold. Vision Research, 39, 2729-2737.
%
%Prins, N. (2013). The psi-marginal adaptive method: how to give nuisance 
%parameters the attention they deserve (no more, no less). Journal of
%Vision, 13(7):3, 1-17. doi: 10.1167/13.7.3
%
%Prins, N. (2022).  Optimizing the classification of observers into 
%distinct and diverse categories. Poster presented at the 22nd annual
%meeting of the Vision Sciences Society. Poster available here:
%https://www.palamedestoolbox.org/VSS2022Prins.html
%
%NP (May, 2022)

optimizeAllorCategoryOnly = input('Optimize all parameters (0) or category membership only (1)? Type 0 or 1: ');
if optimizeAllorCategoryOnly == 1
    marginalize = [1 2 3 4];
else
    marginalize = [];
end

%two possible populations here but can be any number
priorProbA = 1/2;
priorProbB = 1/2;

colors(1,:) = [.8 0 .2]; %red
colors(2,:) = [0 .7 .3]; %green
colors(3,:) = [0 .2 .8]; %blue

classParams = [-1 .5  .5 .25;   %population/category 'A': [Location ('threshold') mean, location standard deviation, log10(slope) mean, log10(slope) standard deviation]
                1 .5 -.5 .25];  %same for population 'B'

%Plotting:
xFine = -10:.1:10;
nSamples = 10000; 
for population = 1:2
    
    for Sample = 1:nSamples
        params = [randn(1)*classParams(population,2)+classParams(population,1),randn(1)*classParams(population,4)+classParams(population,3)];
        for xIndex = 1:length(xFine)
            Ps(xIndex,Sample) = PAL_CumulativeNormal([params(1) 10.^params(2) 0.25 .02],xFine(xIndex));
        end
    end
    Ps = sort(Ps,2);
    hdi68_low(population,:) = Ps(:,.16*nSamples);
    hdi68_high(population,:) = Ps(:,.84*nSamples);
    hdi95_low(population,:) = Ps(:,.025*nSamples);
    hdi95_high(population,:) = Ps(:,.975*nSamples);
    
end

%Set up psi
NumTrials = 30;

grain = 51; %grain of parameter grid

PF = @PAL_CumulativeNormal; %assumed psychometric function

%Stimulus values the method can select from
stimRange = (linspace(-10,10,61));

%Define parameter ranges to be included in posterior
priorAlphaRange = linspace(-3,3,grain);     %Location ('threshold')
priorBetaRange =  linspace(-1.5,1.5,grain); %log10(Slope)
priorGammaRange = .25;                      %Guess rate. Fixed value (using vector here would make it a free parameter) 
priorLambdaRange = .02;                     %Lapse rate. Fixed value (using vector here would make it a free parameter) 
priorModelRange = 1:2;                      %Any (positive integer) number of models is possible

%Define populations by way of prior
[a, b, g, l, m] = ndgrid(priorAlphaRange,priorBetaRange,priorGammaRange,priorLambdaRange,priorModelRange);
prior = zeros(size(a));
prior(:,:,:,:,1) = PAL_pdfNormal(a(:,:,:,:,1),-1,.5).*PAL_pdfNormal(b(:,:,:,:,2),.5,.25);       %population 'A'
prior(:,:,:,:,2) = PAL_pdfNormal(a(:,:,:,:,2),1,.5).*PAL_pdfNormal(b(:,:,:,:,2),-.5,.25);       %population 'B'
prior(:,:,:,:,1) = priorProbA.*prior(:,:,:,:,1)/sum(sum(sum(sum(sum(prior(:,:,:,:,1))))));
prior(:,:,:,:,2) = priorProbB.*prior(:,:,:,:,2)/sum(sum(sum(sum(sum(prior(:,:,:,:,2))))));

%Initialize PM structure
PM = PAL_AMPM_setupPM('priorAlphaRange',priorAlphaRange,...
                      'priorBetaRange',priorBetaRange,...
                      'priorGammaRange',priorGammaRange,...
                      'priorLambdaRange',priorLambdaRange,...
                      'priorModelRange',priorModelRange,...
                      'numtrials',NumTrials,...
                      'PF' , PF,...
                      'stimRange',stimRange,...
                      'marginalize',marginalize,...
                      'prior',prior,...                  
                      'GPU',0);%set to 1 (true) if you have compatible GPU and parallel computing toolbox

paramsGen = [-1, 10.^.5, .25, .02]; %Simulated observer corresponds to model of population 'A' ([location, slope, guess, lapse])

%Plotting:
[xgrid ygrid] = ndgrid(linspace(-2.5,2.5,grain),linspace(-1.25,1.25,grain));

f1 = figure('units','normalized','position',[.1 .1 .8 .8],'color','w');
ax1 = axes('units','normalized','position',[.5 .6 .48 .35]);
hold on
top = max(max(max(PM.pdf)));
set(gca,'FontSize',16,'xtick',[-2:2],'ytick',[-2:2],'ztick',[])
set(gca,'cameraposition',[-15.3461 -9.3803 10*top]);%0.0979])
set(gca,'zcolor',[1 1 1])
set(gca,'ylim',[-1.25 1.25])
set(gca,'xlim',[-2.5 2.5])
box off
surf(xgrid,ygrid,sum(PM.pdf,5));
xlabel('Location (''Threshold'')')
ylabel('log Slope')

ax2 = axes('units','normalized','position',[.1 .6 .35 .35]);
hold on
plot([0],[priorProbA],'-');
set(ax2,'xtick',[0 1])
set(ax2,'ylim',[0 1],'ytick',[0 .5 1],'yticklabel',{'0','.5','1'},'linewidth',2,'fontsize',14)
xlabel('Trial')
ylabel('probability(A)')
box on

ax3 = axes('units','normalized','position',[.1 .1 .85 .4]);
hold on;
for population = 1:2
    plot(xFine,PF([classParams(population,1) 10.^classParams(population,3) .25 .02],xFine),'color',colors((population-1)*2+1,:),'linewidth',2);
    p1 = patch([xFine fliplr(xFine)], [hdi95_low(population,:) fliplr(hdi95_high(population,:))], colors((population-1)*2+1,:),'edgecolor',colors((population-1)*2+1,:));
    p1.FaceAlpha = 1/8;
    p1.EdgeAlpha = 1/8;
    p2 = patch([xFine fliplr(xFine)], [hdi68_low(population,:) fliplr(hdi68_high(population,:))], colors((population-1)*2+1,:),'edgecolor',colors((population-1)*2+1,:));
    p2.FaceAlpha = 1/4;
    p2.EdgeAlpha = 1/4;
end

set(ax3,'ylim',[0 1],'ytick',[0 .5 1],'yticklabel',{'0','.5','1'},'linewidth',2,'fontsize',14)
xlabel('Stimulus Intensity')
ylabel('prop correct')
box on

disp('Hit any key to start trial sequence');
pause

%trial loop
for trial = 1:NumTrials

    response = rand(1) < PF(paramsGen, PM.xCurrent);    %simulate observer's response to optimally placed stimulus

    %update PM based on response
    PM = PAL_AMPM_updatePM(PM,response);

    %Plot stuff
    cla(ax1);
    surf(ax1,xgrid,ygrid,sum(PM.pdf,5));
    top = max(max(max(PM.pdf)));
    set(ax1,'cameraposition',[-15.3461 -9.3803 10*top]);%0.0979])

    cla(ax2);
    set(ax2,'xlim',[0 trial],'xtick',[0 trial])
    plot(ax2,[0:trial],[priorProbA PM.model(1:trial,1)'],'-','linewidth',2,'color',colors(1,:));
    
    cla(ax3)
    for population = 1:2
        plot(ax3,xFine,PF([classParams(population,1) 10.^classParams(population,3) .25 .02],xFine),'color',colors((population-1)*2+1,:),'linewidth',2);
        p1 = patch(ax3,[xFine fliplr(xFine)], [hdi95_low(population,:) fliplr(hdi95_high(population,:))], colors((population-1)*2+1,:),'edgecolor',colors((population-1)*2+1,:));
        p1.FaceAlpha = 1/8;
        p1.EdgeAlpha = 1/8;
        p2 = patch(ax3,[xFine fliplr(xFine)], [hdi68_low(population,:) fliplr(hdi68_high(population,:))], colors((population-1)*2+1,:),'edgecolor',colors((population-1)*2+1,:));
        p2.FaceAlpha = 1/4;
        p2.EdgeAlpha = 1/4;
    end
    plot(ax3,xFine,PF([PM.threshold_cond(trial,1) 10.^PM.slope_cond(trial,1) priorGammaRange priorLambdaRange],xFine),'linewidth',2,'color','k');
    
    [xG yG nG] = PAL_PFML_GroupTrialsbyX(PM.x(1:end-1),PM.response,ones(size(PM.response)));
    for xIndex = 1:length(xG)
        plot(ax3,xG(xIndex),yG(xIndex)/nG(xIndex),'o','markersize',30*sqrt(nG(xIndex)./max(nG)),'color',[0.8 0 0.2],'markerfacecolor',[0.8 0 0.2]);
    end

    drawnow
    pause(.5)

end


