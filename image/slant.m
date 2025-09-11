function  Z = slant(X,Y,theta)

%SLANT -- Sloping plane through the origin.
%   
%  Z = slant(X,Y,params)
%
%  X and Y are matrices produced by MESHGRID.
%  THETA is an angle (in radians) measured from the vertical. The points
%  along any line colinear with that direction have equal Z values.
%
%  Alternatively, Z can be interpreted as the distance from point (x,y)
%  to the line that goes through the origin and has orientation THETA.
%
%  Example:
%    x=[-100:+100] ; y=[-120:+120] ; [X,Y] = meshgrid(x,y) ;
%    imagesc1(x,y,slant(X,Y,10*pi/180)) ;
%
%  See also GRATING, MESHGRID.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/29 20:30 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

Z = X*cos(theta) + Y*sin(theta) ;

%--- Return Z
%%%%% End of file SLANT.M
