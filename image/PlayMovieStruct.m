function [startTime,finishTime] = PlayMovieStruct(movieStruct,safep,warnp)

%PLAYMOVIESTRUCT -- RUSHes the PsychToolbox movie loaded in a movieStruct.
%  
%  [startTime,finishTime] = PlayMovieStruct(movieStruct,[safep],[warnp])
%
%  Hides the cursor, plays the movie, and shows the cursor again.
%  MOVIESTRUCT must be created by MakeMovieStruct and valid grayscale
%  images must be loaded in it by LoadMovieStruct. See MovieStructDemo.
%
%  This function checks whether MOVIESTRUCT has a 'loop' field.
%  If there is, it RUSHes the loop (with movieStruct's PriorityLevel),
%  thereby playing the movie. If there isn't a 'loop' field,
%  PlayMovieStruct makes one (via UNROLLMOVIELOOP) and then RUSHes it.
%  The MOVIESTRUCT is left intact and can be used to re-play the same
%  images or, after another LOADMOVIESTRUCT, to play a different movie.
%  Use CLONEMOVIESTRUCT to play a movie at different locations.
%
%  When SAFEP is 1, PlayMovieStruct makes sure all RUSHed functions are
%  in memory before entering the loop. Default SAFEP=0.
%  When WARNP is 1 (the default), PlayMovieStruct checks the timing
%  and issues a warning if FINISHTIME is less than STARTTIME. To that
%  end, the loop must set the variables 'startTime' and 'finishTime'.
%  The loops prepared by UNROLLMOVIELOOP (and hence MAKEMOVIESTRUCT)
%  do include calls 'startTime=GetSecs;' and 'finishTime=GetSecs;'.
%
%  See also MAKEMOVIESTRUCT, MOVIESTRUCTDEMO, UNROLLMOVIELOOP, RUSH.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/10 16:10 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

if (nargin < 2)   safep = 0 ;  end    % default
if (nargin < 3)   warnp = 1 ;  end    % default

%-- Unpack the movieStruct fields
if (isfield(movieStruct,'loop'))
   loop = movieStruct.loop ;
else
   loop = UnrollMovieLoop(movieStruct) ;
end
PriorityLevel = movieStruct.priority ;

%-- Let's roll...
startTime  = 0 ;
finishTime = -1 ;

HideCursor ;
if safep
   SCREEN('Screens') ; GetSecs ; % Make sure all RUSHed funs are in memory
end
RUSH(loop,PriorityLevel) ;       % <-- sic
ShowCursor ;

%-- startTime and finishTime must now be set
if (warnp & (startTime > finishTime))
   warning(sprintf('Problems with movie: startTime=%g, finishTime=%g',...
           startTime,finishTime)) ;
end

%--- Return STARTTIME and FINISHTIME
%%%%% End of file PLAYMOVIESTRUCT .M
