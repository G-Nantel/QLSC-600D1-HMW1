function  H = butterworth2(Fx,Fy,theta,cutoff)

%BUTTERWORTH2 -- Wedge-like Butterworth lowpass filter in two dimensions.
%  
%  H = butterworth2(Fx,Fy,theta,cutoff)
%
%  Fx and Fy are matrices produced by FFTMESH or MESHGRID.
%  THETA is a scalar that specifies the direction of the midline of the
%  wedge (in radians, see SLANT).
%  CUTOFF is a scalar specifying the width of the wedge one unit away from
%  its tip. For instance, consider a vertical wedge (THETA=0). Then the
%  gain at the point with coordinates (CUTOFF,1) is 50% of the max gain.
%
%  Example 1:
%    x=[-32:32]/64 ; y=x ; [X,Y]=meshgrid(x,y) ;
%    H = butterworth2(X,Y,pi/4,0.25) ;
%    imagesc1(x,y,H) ;
%
%  Example 2 (a brief look inside the function FILTNOISE):
%    [Fx,Fy] = fftmesh(128) ;
%    H = butterworth2(Fx,Fy,(15+90)*pi/180,0.25) ;
%    white_noise = randn(128) ;
%    pink_noise = filter_img(white_noise,H) ;
%    imagesc1(pink_noise) ; truesize ;
%
%  See also BUTTERWORTH1, FILTER_IMG, FILTNOISE, FFTMESH, BANDPASS2.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/29 20:35 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Distance from the midline of the wedge
D = slant(Fx,Fy,theta) ;

%-- The cutoff grows linearly along the perpendicular direction
C = cutoff*abs(slant(Fx,Fy,theta+pi/2)) ;

%-- Calculate a wedge with falloff according to BUTTERWORTH1.
H = butterworth1(D,C) ;

%--- Return H
%%%%% End of file BUTTERWORTH2.M
