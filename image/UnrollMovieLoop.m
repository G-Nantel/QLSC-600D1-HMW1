function  loop = UnrollMovieLoop(movieStruct)

%UNROLLMOVIELOOP -- Make a RUSHable string of SCREEN calls.
%  
%  loop = UnrollMovieLoop(movieStruct)
%
%  MOVIESTRUCT must be created by MakeMovieStruct (see MovieStructDemo).
%  LOOP is a cell array of strings suitable for passing to RUSH.
%  All data such as buffer pointers, source and destination rectangles,
%  number of WaitFrames for each image, etc. are spliced into the
%  strings themselves. Thus LOOP can be RUSHed independently of the
%  movieStruct, although this is not recommended. The recommended way
%  of playing the movie is via PlayMovieStruct.
%  All frame iterations are included as explicit SCREEN calls; there
%  is no FOR statement. The projection is wrapped in calls to GetSecs,
%  recorded in the variables 'startTime' and 'finishTime', respectively.
%
%  You must update the loop whenever you tinker with the data fields of
%  a movieStruct:  movieStruct.loop = UnrollMovieLoop(movieStruct) ;
%  The constructors MakeMovieStruct and CloneMovieStruct do it by default.
%  You need not update the loop after you have loaded new images into
%  the buffers (see LoadMovieStruct) or played the movie (PlayMovieStruct).
%
%  [ver 1.1] The 'srcCopyQuickly' modifier is omitted per Dennis Pelli's
%  advice:  ...On most computers today CopyWindow will run faster if
%  you OMIT 'srcCopyQuickly'...
%  See PsychToolbox discussion forum, message 392 of Mar 10, 2001,
%  http://groups.yahoo.com/group/psychtoolbox/message/392
%
%  Example:
%  >> movieStruct = MakeMovieStruct(winPtr,[32 24;12 12],[],[],[1 2]) ;
%  >> loop = UnrollMovieLoop(movieStruct)
%  loop =
%    'SCREEN(47495840,'WaitBlanking');'
%    'startTime=GetSecs;'
%    'SCREEN('CopyWindow',47495520,47495840,[0 0 24 32],[308 224 332 256]);'
%    'SCREEN(47495840,'WaitBlanking',1);'
%    'SCREEN('CopyWindow',47496400,47495840,[0 0 12 12],[314 234 326 246]);'
%    'SCREEN(47495840,'WaitBlanking',2);'
%    'finishTime=GetSecs;'
%
%  See also PLAYMOVIESTRUCT, MAKEMOVIESTRUCT, MOVIESTRUCTDEMO, RUSH.

% Original coding by Alexander Petrov, Ohio State University.
% $Revision: 1.1 $  $Date: 2005/01/26 09:51 $  -- omit srcCopyQuickly
% Old version: 1.0  $Date: 2001/12/09 20:43 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Unpack the fields
winPtr = movieStruct.windowPtr ;
bufferPtr = movieStruct.bufferPtr ;
winRect = movieStruct.windowRect ;
imageRect = movieStruct.imageRect ;
destRect = movieStruct.destRect ;
sequence = movieStruct.sequence ;
repets = movieStruct.repets ;

nImages = length(bufferPtr) ;
nItems = length(sequence) ;
nFrames = sum(repets) ;

%-- Prepare the LOOP
%-- Note that all pointers, rectangles, etc. are hardwired in the strings.
loop = cell(2+2*nItems+1,1) ;
loop{1} = sprintf('SCREEN(%u,''WaitBlanking'');',winPtr) ;
loop{2} = 'startTime=GetSecs;' ;
t = 3 ;
for k = 1:nItems
  whichImage = sequence(k) ;
  srcRect = imageRect(whichImage,:) ;
  dstRect = destRect(whichImage,:) ;
  loop{t} = sprintf('SCREEN(''CopyWindow'',%u,%u,%s,%s);',...
                    bufferPtr(whichImage),winPtr,...
                    rect2str(srcRect),rect2str(dstRect) ) ;
  loop{t+1} = sprintf('SCREEN(%u,''WaitBlanking'',%d);',winPtr,repets(k)) ;
  t = t+2 ;               
end
loop{t} = 'finishTime=GetSecs;' ;

%--- Return LOOP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = rect2str(rect)
str = sprintf('[%d %d %d %d]',rect(1),rect(2),rect(3),rect(4)) ;
%-- Return STR from subfunction RECT2STR

%%%%% End of file UNROLLMOVIELOOP.M
