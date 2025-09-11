function   M = mosaic(image_sz,grain_sz,randomize)

%MOSAIC -- An image of random black and white tiles.
%
% M = mosaic(image_sz,grain_sz)
% M = mosaic(image_sz,grain_sz,randomize)
%
% IMAGE_SZ defines the size of the mosaic (N is shorthand for [N N]).
% GRAIN_SZ defines the size of the individual pieces (n --> [n n]).
% IMAGE_SZ must be evenly divisible by GRAIN_SZ within each dimension.
% The result M is a matrix of black (0s) and white (1s) rectangles.
% RANDOMIZE specifies whether to radomize=1=default or to alternate=0 
% the black and white pieces. When randomized, the program makes sure 
% to use an (almost) equal number of each color.
%
% Example:
%  for k=1:4 subplot(2,2,k);imagesc(mosaic([40 64],8),[0 1]);end
%
% See also REPPIX, FIND, RANDPERM.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2005/03/24 17:10 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Handle arguments
if  (length(image_sz)==1)  image_sz = [image_sz image_sz] ; end
if  (length(grain_sz)==1)  grain_sz = [grain_sz grain_sz] ; end
if  (nargin<3) randomize = 1 ; end

%-- Determine sizes
ROWS = image_sz(1) ; COLS = image_sz(2) ;
rows = grain_sz(1) ; cols = grain_sz(2) ;
Nrows = ROWS/rows ;  Ncols = COLS/cols ;
if ((Nrows~=fix(Nrows)) | (Ncols~=fix(Ncols)))
   error('IMAGE_SZ must be evenly divisible by GRAIN_SZ.') ;
end

%-- Make a small checkerboard
if (randomize==0)    % alternate, top left always 1
   WBcol = mod([1:Nrows]',2) ;
   checker = repmat([WBcol 1-WBcol],1,ceil(Ncols/2)) ;
   if (mod(Ncols,2)==1)  checker(:,Ncols+1) = [] ; end
else
   checker = zeros(Nrows,Ncols) ;
   randidx = randperm(Nrows*Ncols) ;
   randidx = randidx(1:ceil(Ncols*Nrows/2)) ;
   checker(randidx) = 1 ;
end

%-- Replicate and return
M = reppix(checker,rows,cols) ;   % [Nrows,Ncols] --> [ROWS,COLS]

%--- Return M
%%%%% End of MOSAIC.M
