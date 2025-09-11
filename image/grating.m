function  G = grating(X,Y,params)

%GRATING --  Sinusoidal grating (grayscale image).
%   
%  G = grating(X,Y,params)
%
%  X and Y are matrices produced by MESHGRID (use integers=pixels).
%  PARAMS is a struct w/ fields 'amplit', 'freq', 'orient', and 'phase'.
%  The function GABOR_PARAMS supplies default parameters.
%  G is a matrix of luminance values.  size(G)==size(X)==size(Y)
%
%  Example:
%    x=[-100:+100] ; y=[-120:+120] ; [X,Y] = meshgrid(x,y) ;
%    params = gabor_params ; params.orient = 15*pi/180 ;
%    G = grating(X,Y,params) ;
%    imagesc1(x,y,G) ;
%
%  See also GABOR, GABOR_PARAMS, SLANT, MESHGRID.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/29 12:55 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

if (nargin<2)
   error('At least two input arguments expected: X and Y.') ;
elseif (nargin==2)
   params = gabor_params ;    % default parameters
end

A = params.amplit ;
omega = 2*pi*params.freq ;
theta = params.orient ;
phi = params.phase ;

slant = X*(omega*cos(theta)) + Y*(omega*sin(theta)) ;  % cf. function SLANT
G = A*cos(slant+phi) ;

%--- Return G
%%%%% End of file GRATING.M
