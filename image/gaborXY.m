function  G = gaborXY(X,Y,params)

%GABOR  --  Sinusoidal grating under a Gaussian envelope.
%   
%  G = gabor(X,Y,params)
%
%  X and Y are matrices produced by MESHGRID (use integers=pixels).
%  PARAMS is a struct with fields 'amplit', 'freq', 'orient', 'phase',
%  and 'sigma'. The function GABOR_PARAMS supplies default parameters.
%  G is a matrix of luminance values.  size(G)==size(X)==size(Y)
%
%  Example:
%    x=[-100:+100] ; y=[-120:+120] ; [X,Y] = meshgrid(x,y) ;
%    params = gabor_params ; params.orient = 60*pi/180 ;
%    G = gabor(X,Y,params) ;
%    imagesc1(x,y,G) ;
%
%  See also GRATING, GABOR_PARAMS, MESHGRID.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/29 17:05 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

% modif Alex XY

if (nargin<2)
   error('At least two input arguments expected: X and Y.') ;
elseif (nargin==2)
   params = gabor_params ;    % default parameters
end

sigmaXsq = params.sigmaX ^2 ;
sigmaYsq = params.sigmaY ^2 ;

% Gaussian = exp(-(X.^2+Y.^2)./(2*sigmasq)) ;
Gaussian = exp(-((X.^2)./(2*sigmaXsq)+(Y.^2)./(2*sigmaYsq))) ;

Grating = grating(X,Y,params) ;
G = Gaussian.*Grating ;

%--- Return G
%%%%% End of file GABOR.M
