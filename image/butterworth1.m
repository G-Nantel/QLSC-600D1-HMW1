function  H = butterworth1(D,cutoff)

%BUTTERWORTH1 -- One-dimensional Butterworth lowpass filter of order 1.
%   
%  H = butterworth1(D,cutoff)
%
%  D is a vector (or matrix) of distances to the focal point (or line)
%  of the filter in Fourier space. Negative values are OK.
%  CUTOFF is either a scalar or an array of the same size as X.
%  It specifies the "cutoff frequency locus" -- the point at which the
%  gain of the filter goes to 50% of its maximum value.
%
%  Reference:  Gonzalez, R.C. & Woods, R.E. (1992). Digital image
%    processing [Eq. 4.4-4, p.208]. Reading, MA: Addison-Wesley.
%
%  Example:   % one dimension
%    x=[-3:0.1:3] ;
%    plot(x,butterworth1(x,1)) ;    % Figure 4.34(b) in the book
%
%  Example:   % two dimensions
%    x=[-3:0.1:3] ; y=[-3:0.1:3] ; [X,Y]=meshgrid(x,y) ;
%    D = sqrt(X.^2+Y.^2) ;
%    H = butterworth1(D,1) ;
%    imagesc1(x,y,H) ;             % Figure 4.34(a) in the book
%
%  Do not confuse with BUTTER in the signal processing toolbox.
%  See also BUTTERWORTH2, BUTTER, BANDPASS.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2008-02-22 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2008, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

C = max(cutoff,realmin) ;    % avoid division by zero

H = 1 ./ (1 + (D./C).^2) ;

%--- Return H
%%%%% End of file BUTTERWORTH1.M
