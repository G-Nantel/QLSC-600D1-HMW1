function  fimg = filter_img(img,F)

%FILTER_IMG -- Filter a grayscale image in the frequency domain.
%   
% fimg = filter_img(img,F)
%
% IMG is a grayscale image. F is a matrix of the same size specifying the
% filter transfer function. (See FFTMESH for the arrangement conventions.)
% The function takes the Fourier transform of IMG (using FFT2), multiplies
% it by F, applies IFFT2 to the product, and returns its real part.
%
% See also FFT2, BUTTERWORTH2, FFTMESH, FILTER2.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/30 10:30 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

H = fft2(img) ;             % move to the frequency domain
FH = F.*H ;                 % apply the filter
fimg = real(ifft2(FH)) ;    % move back to the spatial domain

%--- Return FIMG
%%%%% End of file FILTER_IMG.M
