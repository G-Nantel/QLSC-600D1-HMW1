function newimg = reppix(img,M,N)

%REPPIX -- Replicates pixels in an image thus producing a larger image.
%
%  newimg = reppix(img,M,N)
%  newimg = reppix(img,[M,N])
%  newimg = reppix(img,M)      is a shorthand for  reppix(img,M,M)
% 
%  IMG is an image (but the function works for arbitrary matrices).
%  M and N are integers. Each pixel of the original IMG is replaced by
%  an MxN patch of identical pixels in NEWIMG. No interpolation is 
%  attempted (use IMRESIZE for that).
%
%  See also IMRESIZE, REPMAT, MOSAIC.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/08 17:10 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

if (length(M) == 1)
   if (nargin == 2)       % shorthand: M --> [M M]
      N = M ;
   end
elseif (length(M) == 2)
   N = M(2) ;
   M = M(1) ;
else
   error('At most two dimensions supported: M and N.') ;
end

[rows,cols] = size(img) ;
newimg = zeros(M*rows,N*cols) ;

K = [1:M] ;
for k=1:rows
   L = [1:N] ;
   for l=1:cols
      newimg(K,L) = img(k,l) ;
      L = L + N ;
   end
   K = K + M ;
end


%--- Return NEWIMG
%%%%% End of REPPIX.M
