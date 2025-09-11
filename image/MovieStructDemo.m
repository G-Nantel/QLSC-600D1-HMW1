function  MovieStructDemo(whichScreen)

%MOVIESTRUCTDEMO -- Demo of PsychToolbox movies and "movieStructs".
%
%  MovieStructDemo([whichScreen])
%
%  Demonstration of MakeMovieStruct, LoadMovieStruct, and PlayMovieStruct.
%  These three functions provide a user-friendly interface to the 
%  PsychToolbox routines for playing "movies" (and in particular RUSH,
%  SCREEN.OpenOffscreenWindow, SCREEN.CopyWindow, and SCREEN.WaitBlanking).
%
%  WHICHSCREEN is 0 for the main screen and 1 for the auxiliary screen,
%  if any (see SCREEN.OpenWindow). If not supplied, it defaults to 0.
%
%  The overall methodology is the following:
%  First, one opens a SCREEN window in the usual way (see MovieDemo2).
%  Second, one creates a "movieStruct" by calling MakeMovieStruct.
%  The movieStruct is the skeleton of a movie -- a structure with various
%  fields containing information about the number of frames, buffers in
%  which the individual images will be loaded, and a "RUSH loop".
%  Third, one loads the specific images into the movieStruct buffers
%  by calling LoadMovieStruct. The same movieStruct can be re-used many
%  times with different images, as long as the overall number of images
%  and their respective sizes remain constant (see CLONEMOVIESTRUCT).
%  Finally, one calls PlayMovieStruct to actually play the movie.
%
%  See also MOVIEDEMO2, MAKEMOVIESTRUCT, PLAYMOVIESTRUCT, SCREEN.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/09 20:29 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

if (nargin < 1)
   whichScreen = 0 ;     % use the main screen by default
end
fprintf('\n*** MovieStruct Demo ***\n\nType ''helpwin MovieStructDemo''') ;
fprintf(' or ''edit MovieStructDemo'' for details.\n\n') ;

%-- Prepare the IMAGES -- a rotating sequence of gratings and Gabor patches
domain = [-64:+64] ;
[X,Y] = meshgrid(domain) ;
params = gabor_params ; params.freq = 1/20 ;   % 20 pixels/cycle
theta = [0:0.125:2]'*pi ;
gray = 128 ;     % index in the default lookup table

nImages = length(theta) ;
imgSz = size(X) ;
gratings = zeros([imgSz nImages]) ;
gabors = zeros([imgSz nImages]) ;
for k = 1:nImages
   params.orient = theta(k) ;
   gratings(:,:,k) = fix(grating(X,Y,params).*255+gray) ;
   gabors(:,:,k) = fix(gabor(X,Y,params).*255+gray) ;
end

%-- Open a SCREEN window to play the movie on
%   This must be done before creating the movieStruct so that the 
%   offscreen buffers can be aligned to onscreen for faster copying.
[winPtr,winRect] = SCREEN(whichScreen,'OpenWindow',gray,[],8) ;
    % You can also set up the lookup table at this point.

%-- Create the skeleton of the movie
%   The SEQUENCE is two play IMAGES forwards and then backwards.
%   Each image stays on screen for 10 frames on the forward and 5
%   frame on the backward pass.
fwReps = 10 ; bwReps = 5 ;
Gabor_offsets = [0,0] ;      % show Gabors at the center of the screen
grating_offsets = [0,100] ;  % show gratings 100 pixels below center
sequence = [[1:+1:nImages] [nImages:-1:1]] ;
repetitions = [repmat(fwReps,1,nImages) repmat(bwReps,1,nImages)] ;
movieStruct = MakeMovieStruct(winPtr,repmat(imgSz,nImages,1),...
                              Gabor_offsets,sequence,repetitions) ;

fprintf('The movie size is %d by %d.\n',imgSz(1),imgSz(2)) ;
fprintf('%d frames (%d*%d forward + %d*%d backward).\n',...
        sum(repetitions),fwReps,nImages,bwReps,nImages) ;

%-- Load the gratings and wait for a click
LoadMovieStruct(gratings,movieStruct) ;

SCREEN(winPtr,'TextFont','Helvetica') ;
SCREEN(winPtr,'TextSize',18) ;
ShowCursor(0) ;   % arrow cursor
ask(winPtr,'Click the mouse to show gratings...',255,gray) ;

%-- Play the movie and report the timing on the console
%   This will not be immediately visible when WHICHSCREEN==0.
[startTime,finishTime] = PlayMovieStruct(movieStruct) ;
SCREEN(winPtr,'FillRect',gray) ;        % clear the screen

playTime = 1000 * (finishTime-startTime) ;   % in milliseconds
fprintf('Showed grating movie in %.3f seconds, %.3f msec/frame.\n',...
        playTime/1000,playTime/sum(repetitions)) ;

%-- Load and play the gratings
%   Notice that the cloned movieStruct re-uses the same buffers.
newStruct = CloneMovieStruct(movieStruct,grating_offsets) ;
LoadMovieStruct(gabors,newStruct) ;
ask(winPtr,'Click the mouse to show Gabor patches...',255,gray) ;
[startTime,finishTime] = PlayMovieStruct(newStruct) ;

playTime = 1000 * (finishTime-startTime) ;
fprintf('Showed Gabor movie in %.3f seconds, %.3f msec/frame.\n',...
        playTime/1000,playTime/sum(repetitions)) ;

%-- Clean up
SCREEN('CloseAll') ;

%%%%% End of file MOVIESTRUCTDEMO.M
