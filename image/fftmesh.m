function  [Fx,Fy] = fftmesh(n)

%FFTMESH -- Fx and Fy domains arranged to dovetail with FFT2.
%   
%  [Fx,Fy] = fftmesh(N)
%  [Fx,Fy] = fftmesh([Nx Ny])
%
%  The fast Fourier transform (FFT, FFT2) outputs the spectrum in a
%  'wraparound' order with positive frequencies first and negative
%  frequencies second (cf. function FFTSHIFT). In order to prepare
%  filters in the frequency domain (for use with FILTER_IMG), it is
%  convenient to work over a mesh with the same 'wraparound' order.
%
%  [Nx Ny] specify the size of the mesh. N is a shorthand for [N N].
%  The fast Fourier transform is most efficient when N is a power of 2.
%  For the unidimensional case, simply use F=FFTMESH([N 1]).
%
%  Reference:  Press,W, Teukolsky,S, Vetterling,W, & Flannery, B. (1992).
%    Numerical Recipes in C [2nd Ed, Eq.12.1.5, p.502]. Cambride U Press.
%
%  See also FFT2, FFTSHIFT, MESHGRID, FILTER_IMG, BUTTERWORTH2, MAKE_GRID.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/30 10:00 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%- Handle the size argument
if (length(n)==1)
   nx = n ; ny = n ;
else
   nx = n(1) ; ny = n(2) ;
end

%- Prepare uni-dimensional indices wrapped appropriately
fx = [[0:ceil(nx/2)-1] [-floor(nx/2):-1]] / nx ;
fy = [[0:ceil(ny/2)-1] [-floor(ny/2):-1]] / ny ;

%- Make the mesh
[Fx,Fy] = meshgrid(fx,fy) ;

%--- Return Fx and Fy
%%%%% End of file FFTMESH.M
