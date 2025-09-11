function  fnoise = filtnoise(F,range,outcut,rawnoise)

%FILTNOISE -- Gaussian noise filtered through a user-supplied filter.
%  
%  fnoise = filtnoise(F)
%  fnoise = filtnoise(F,range)
%  fnoise = filtnoise(F,range,outcut)
%  fnoise = filtnoise(F,range,outcut,rawnoise)
%
%  This function begins with RAWNOISE, filters it through the filter F,
%  and returns the resulting image after some post-processing.
%  It is guaranteed that all pixel intensities fall within RANGE and
%  that the mean intensity is exactly MEAN(RANGE).
%
%
%  F is the frequency response of the filter (see FILTER_IMG and FFTMESH).
%  RANGE specifies the min and max intensities of the resulting image.
%  OUTCUT is the number of standard deviation units allowed before a point
%  becomes an outlier and is trimmed towards the mean. 0='no trimming'.
%  If not supplied, RANGE defaults to [0 1] and OUTCUT to 4.0.
%
%  RAWNOISE must be an intensity image of the same size as the matrix F.
%  When not supplied, Gaussian noise with mean 0 and sigma 0.15 is used.
%  Each pixel is generated independently and clipped b/n -0.5 and +0.5.
%
%  Example:
%    [Fx,Fy]=fftmesh(128) ; F=butterworth2(Fx,Fy,(15+90)*pi/180,0.25) ;
%    imagesc1(filtnoise(F)) ; truesize ;
%
%  See also FILTER_IMG, BUTTERWORTH2, RANDN.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/04 19:03 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Supply default params if necessary
if (nargin < 2)   range = [0 1] ;  end
if (nargin < 3)   outcut = 4 ;  end
if (nargin < 4)
   %- Generate RAWNOISE from scratch, a likely scenario.
   rawnoise = 0.15*randn(size(F)) ;           % mean=0, sigma=0.15
   rawnoise = max(-0.5,min(rawnoise,+0.5)) ;  % min=-0.5, max=+0.5
elseif (any(size(rawnoise)~=size(F)))
   error('RAWNOISE must have the same size as the filter F.') ;
end

%-- Do the main work (involves FFT)
filtered = filter_img(rawnoise,F) ;

%-- Remove outliers
if (outcut > 0)
   mu = mean(filtered(:)) ;
   sigma = std(filtered(:)) ;
   low  =  mu - outcut*sigma ;
   high =  mu + outcut*sigma;
   filtered = max(low,min(filtered,high)) ;
end

%-- Rescale and return.
low = min(filtered(:)) ;
mu = mean(filtered(:)) ;
high = max(filtered(:)) ;
curr_range = 2*max(mu-low,high-mu) ;  % force mean(fnoise(:))=mean(range)

scale = (range(2) - range(1)) / curr_range ;
fnoise = filtered.*scale + (mean(range) - mu*scale) ;

%--- Return FNOISE
%%%%% End of file FILTNOISE.M
