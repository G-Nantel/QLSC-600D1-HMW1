function  M = RDC_movie(Rparams,RDC)

%RDC_MOVIE -- Animation of a random-dot cinematogram as a Matlab movie
%   
%  M = RDC_movie(Rparams,RDC)
%
%  Rparams is a structure produced by RDC_PARAMS.
%  RDC is a either a RDC specification produced by MAKE_RDC_SPEC or
%  a rendered RDC movie (3D stack of images) produced by RENDER_RDC.
%
%  The function plots each frame using PLOT, captures it
%  using GETFRAME, and returns the resulting movie M.
%
%  NOTE: RDC_MOVIE is good for debugging and visualization purposes only.
%  NOTE: Use RENDER_RDC from inside PsychToolbox for accurate presentations.
%
%  Example:
%    Rparams = RDC_params ; RDC_spec = make_RDC_spec(Rparams,45,50) ;
%    M1 = RDC_movie(Rparams,RDC_spec)   % generate while playing
%    movie(M1,3)                        % replay 3 times
%    RDC = render_RDC(Rparams,RDC_spec) ;
%    figure(2) ; M2 = RDC_movie(Rparams,RDC) ; movie(M2,3)
%
%  See also RDC_PARAMS, MAKE_RDC_SPEC, RENDER_RDC, MOVIE, PLOT, GETFRAME.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.1 $  $Date: 2007-12-06 $
%
% Part of the utils toolbox version 1.2 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2008, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

% 1.1  2007-12-06 ap -- New RDC_spec format for MAKE_RDC_SPEC v.2.0

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2006/06/06 17:08 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

N_frames = size(RDC,3) ;

if (ismember(size(RDC,2),[2 3]))    % if RDC spec
    %- Set the stage
    axis([-.55 .55 -.55 .55] .* Rparams.aperture) ; axis square ;
    M = moviein(N_frames) ;   % for backward compatibility, no longer needed
    set(gca,'NextPlot','replacechildren') ;  % don't reset axis in the loop
    %- Play and store the movie
    for t = 1:N_frames
        plot(RDC(:,1,t),RDC(:,2,t),'.') ;
        M(:,t) = getframe ;
    end
else  % RDC is a rendered sequence of grayscale images
    %- Set the stage
    x = Rparams.x ;
    y = Rparams.y ;
    imagesc(x,y,flipud(RDC(:,:,1)),[0 255]) ;
    axis square ; axis xy ; colormap gray ;
    M = moviein(N_frames) ;   % for backward compatibility, no longer needed
    set(gca,'NextPlot','replacechildren') ;  % don't reset axis in the loop
    %- Play and store the movie
    for t = 1:N_frames
        imagesc(x,y,flipud(RDC(:,:,t)),[0 255]) ;
        M(:,t) = getframe ;
    end
end

%--- Return M
%%%%% End of file MAKE_RDC_SPEC.M
