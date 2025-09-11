function  [descr,ex,ey] = elliptic_CI(X,Y,Pcrit)

%ELLIPTIC_CI -- Elliptic confidence region for bivariate Gaussian data.
%
%  @@@@@ BUGGED!  DO NOT USE!! A method for calculating the critical @@@@@@
%  @@@@@ BUGGED!  level is needed. Analogous to univariate CHI2INV.  @@@@@@
%
%  descr = covar2elliptic_CI(X,Y,Pcrit)
%  [descr,ex,ey] = covar2elliptic_CI(X,Y,Pcrit)
%
%  X and Y are data vectors (or arbitrary matrices).
%  PCRIT defines the contour level. Default 90%.
%  The function generates a DESCR structure suitable for passing 
%  to COVAR2ELLIPSE and CHFUN.
%  EX and EY are ELLIPSE_POINTS suitable for plotting.
%
%  @@ BUG:  The Gaussian integral is implemented without the factor   @@
%  @@ BUG:    1/(2*pi*SIGx*SIGy*sqrt(1-rho^2))                        @@
%  @@ BUG:  Also the critical level should depend on CHI2INV somehow! @@
%
%  Example:
%    X = randn(1000,1) ; Y = randn(1000,1) ; Y = (5-X+3*Y)/6 ;
%    [descr,ex,ey] = elliptic_CI(X,Y,0.90) ; 
%    plot(X,Y,'b.',ex,ey,'r-') ; axis equal ;
%    h=chfun(descr,X,Y);n=sum(h>0);title([int2str(n) ' inside points']);
%
%  See also COVAR2ELLIPSE, ELLIPSE_POINTS, COV, CHFUN, MVNPDF, MVNCDF.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 0.9 $  $Date: 2006/06/13 20:00 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

warning('BUG: The critical level is not implemented properly!!!') ;

if (nargin<3)  Pcrit = 0.90 ; end

%-- Estimate coefficients from data
c = cov(X(:),Y(:)) ;
SIGx = sqrt(c(1,1)) ;
SIGy = sqrt(c(2,2)) ;
rho = c(1,2) / (SIGx*SIGy) ;

descr.isa = 'ellipse' ;
descr.type = [0 1 0] ;
descr.SIGx = SIGx ;
descr.SIGy = SIGy ;
descr.rho = rho ;
descr.Xc = mean(X(:)) ;
descr.Yc = mean(Y(:)) ;
descr.free = log(1-Pcrit) ;  % @@ BUG: Should depend on CHI2INV somehow!!

%-- Call ELLIPSE_POINTS if requested
if (nargout>1)
   [ex,ey] = ellipse_points(covar2ellipse(descr)) ;
end

%--- Return DESCR and possibly EX, EY
%%%%% End of ELLIPTIC_CI.M
