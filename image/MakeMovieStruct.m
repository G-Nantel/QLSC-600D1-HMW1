function  movieStruct = MakeMovieStruct(winPtr,imgSz,offs,seq,rep,prty)

%MAKEMOVIESTRUCT -- Prepare a movie (syntactic sugar to PsychToolbox).
%  
%  movieStruct = MakeMovieStruct(windowPtr,imageSizes,...
%                    [offsets],[sequence],[repetitions],[priorityLevel])
%
%  This function sets the stage for projecting PsychToolbox SCREEN movies.
%  It allocates buffers (via SCREEN.OpenOffscreenWindow), calculates
%  "destination rectangles", and calls UNROLLMOVIELOOP to pre-compile
%  a "RUSH loop".
%  The function produces a "movieStruct" which can then be used repeatedly
%  by loading different images into the buffer (via LOADMOVIESTRUCT) and
%  playing them (PLAYMOVIESTRUCT). See MOVIESTRUCTDEMO for more details.
%
%  WINDOWPTR must be a pointer to an open screen (see SCREEN.OpenWindow).
%  IMAGESIZES must be a Nx2 matrix describing the sizes of the images
%  to be included in the movie as well as their total number N.
%  OFFSETS is a Nx2 matrix of [dx,dy] offsets for each image, measured
%  from the center of the screen. Thus different frames of the movie can
%  appear at different locations. Use 1x2 matrix as a shorthand for Nx2
%  matrix with identical rows. If OFFSET is not supplied, it defaults
%  to zeros(N,2). That is, all images are centered on the screen.
%  SEQUENCE specifies the order of images in the movie. The default
%  is [1 2 ... N] but arbitrary sequences are possible (e.g. [1 2 1 3 1]).
%  REPETITIONS must be a vector of the same length as SEQUENCE. It
%  specifies the number of "waitFrames" the particular item stays on
%  the screen (see SCREEN.WaitBlanking). Default: ones(size(sequence)).
%  PRIORITYLEVEL defaults to MaxPriority(windowPtr,'GetSecs',...
%   'WaitBlanking','PeekBlanking'). See RUSH and MAXPRIORITY for details.
%
%  MOVIESTRUCT is a structure with the following fields:
%   1. windowPtr  - copy of the WINDOWPTR argument, [1x1]
%   2. bufferPtr  - array of pointers to offscreen windows, [Nx1]
%   3. windowRect - rectangle spanning the parent screen window, [1x4]
%   4. imageRect  - array of rectangles coding the image sizes, [Nx4]
%   5. destRect   - array of rectangles at appropriate OFFSETS, [Nx4]
%   6. sequence   - copy of the SEQUENCE argument, [1xS]
%   7. repets     - copy of the REPETITIONS argument, [1xS]
%   8. loop       - cell array of strings pre-compiled by UNROLLMOVIELOOP
%   9. priority   - RUSH priority level, [1x1]
%
%  See also CLONEMOVIESTRUCT, LOADMOVIESTRUCT, MOVIESTRUCTDEMO, SCREEN.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/13 12:57 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Supply default params
N = size(imgSz,1) ;       % number of images == number of buffers
if (nargin < 3)           % OFFSETS not supplied?
   offs = zeros(N,2) ;    % default dx=dy=0 for each image
elseif (isempty(offs))
   offs = zeros(N,2) ;
elseif (size(offs,1)==1)  % shorthand case?
   offs = repmat(offs,N,1) ;
elseif (size(offs,1)~=N)
   error('There must be as many OFFSETS as IMAGESIZES.') ;
end
if (nargin < 4)           % SEQUENCE not supplied?
   seq = [1:N] ;          % default [1 2 ... N]
elseif (isempty(seq))
   seq = [1:N] ;
end
if (nargin < 5)           % REPETITIONS not supplied?
   rep = ones(size(seq)) ;
elseif (isempty(rep))
   rep = ones(size(seq)) ;
elseif (length(rep)==1)   % shorthand case?
   rep = repmat(rep,size(seq)) ;
elseif (length(rep)~=length(seq))
   error('REPETITIONS must be a vector of the same length as SEQUENCE.') ;
end
if (nargin < 6)           % PRIORITYLEVEL not supplied?
   prty = MaxPriority(winPtr,'GetSecs','WaitBlanking','PeekBlanking') ;
end
defaultColor = 0 ;
defaultPixelSize = [] ;   % let SCREEN.OpenOffscreenWindos determine it

%-- Convert IMAGESIZE and OFFSETS into IMAGERECT and DESTRECT
winRect = SCREEN(winPtr,'Rect') ;   % every other RECT is relative to this
[Xcenter,Ycenter] = RectCenter(winRect) ;

imageRect = zeros(N,4) ;       % sourceRect for SCREEN.CopyWindow
imageRect(:,[RectBottom RectRight]) = imgSz ;

destRect = zeros(N,4) ;        % destRect for SCREEN.CopyWindow
for k=1:N
   destRect(k,:) = CenterRectOnPoint(imageRect(k,:),...
                     Xcenter+offs(k,1),Ycenter+offs(k,2));
end

%-- Allocate offscreen buffers
bufferPtr = zeros(N,1) ;       % SCREEN pointers are long integers
for k=1:N
   bufferPtr(k) = SCREEN(winPtr,'OpenOffscreenWindow',...
                         defaultColor,imageRect(k,:),defaultPixelSize) ;
end

%-- Pack everything into a movieStruct and return
movieStruct.windowPtr  = winPtr ;
movieStruct.bufferPtr  = bufferPtr ;
movieStruct.windowRect = winRect ;
movieStruct.imageRect  = imageRect ;
movieStruct.destRect   = destRect ;
movieStruct.sequence   = seq ;
movieStruct.repets     = rep ;
movieStruct.loop       = UnrollMovieLoop(movieStruct) ;   % <-- sic!
movieStruct.priority   = prty ;

%--- Return MOVIESTRUCT
%%%%% End of file MAKEMOVIESTRUCT.M
