function  newStruct = CloneMovieStruct(oldStruct,offs,seq,rep)

%CLONEMOVIESTRUCT -- Clone a movieStruct to another location or sequence.
%  
%  newStruct = CloneeMovieStruct(oldStruct,[offsets],[sequence],[repets])
%
%  OLDSTRUCT must be a "movieStruct" created by MakeMovieStruct.
%  See the latter for the meaning of OFFSETS, SEQUENCE, and REPETITIONS.
%  If an argument is [] or not supplied, it defaults to its corresponding
%  field in OLDSTRUCT.
%  NEWSTRUCT is a movieStruct using the same offscreen buffers as the
%  old one (and hence the same image sizes), but presents the images at
%  different offsets, sequence, and/or repetitions.
%
%  Example:  (Assume WINPTR and IMAGESIZES are properly initialized.)
%   mvS_up = MakeMovieStruct(winPtr,imageSizes,[0 -100]) ; % above center
%   mvS_down = CloneMovieStruct(mvS_up,[0 +100]) ;         % below center
%  
%  See also MAKEMOVIESTRUCT, LOADMOVIESTRUCT, PLAYMOVIESTRUCT.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/13 12:57 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Peel off info from OLDSTRUCT
N = length(oldStruct.bufferPtr) ;
imageRect = oldStruct.imageRect ;

if (nargin < 2)           % OFFSETS not supplied?
   destRect = oldStruct.destRect ;
elseif (isempty(offs))
   destRect = oldStruct.destRect ;
elseif (~ismember(size(offs,1),[1,N]))
   error('There must be as many OFFSETS as oldStruct buffers.') ;
else  % there are new OFFSETS
   if (size(offs,1)==1)  offs = repmat(offs,N,1) ; end   % shorthand
   % Calculate new destination rectangles from scratch
   [Xcenter,Ycenter] = RectCenter(oldStruct.windowRect) ;
   destRect = zeros(N,4) ;
   for k=1:N
      destRect(k,:) = CenterRectOnPoint(imageRect(k,:),...
                            Xcenter+offs(k,1),Ycenter+offs(k,2));
   end
end

if (nargin < 3)           % SEQUENCE not supplied?
   seq = oldStruct.sequence ;
elseif (isempty(seq))
   seq = oldStruct.sequence ;
end
if (nargin < 4)           % REPETITIONS not supplied?
   rep = oldStruct.repets ;
elseif (isempty(rep))
   rep = oldStruct.repets ;
elseif (length(rep)==1)   % shorthand case?
   rep = repmat(rep,size(seq)) ;
end
if (length(rep)~=length(seq))
   error('REPETITIONS must be a vector of the same length as SEQUENCE.') ;
end

%-- Make the clone and return
newStruct = oldStruct ;
newStruct.destRect = destRect ;
newStruct.sequence = seq ;
newStruct.repets   = rep ;
newStruct.loop     = UnrollMovieLoop(newStruct) ;

%--- Return NEWSTRUCT
%%%%% End of file CLONEMOVIESTRUCT.M
