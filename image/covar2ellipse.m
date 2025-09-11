function  descr = covar2ellipse(arg1,xc,yc)

%COVAR2ELLIPSE -- Covariance matrix --> ellipse coefficients.
%
%  descr = covar2ellipse(descrSIGMA)
%  descr = covar2ellipse(covXY)
%  descr = covar2ellipse(covXY,xc,yc)
%  descr = covar2ellipse(covXY,xc,yc)
%
%  Calculates coefficients A,B,C for the iso-likelihood elliptic contours
%  of bivariate Gaussian distribution with covariance matrix COVXY.
%  When not supplied, the marginal means Xc and Yc default to 0.
%  PCRIT is the confidence level. Default = 90%.
%  Alternatively, the inputs may be packed in a structure with fields
%  'isa'='ellipse', 'SIGx','SIGy', 'rho', 'Xc','Yc'.
%
%  The resulting descriptor DESCR is suitable for passing to the
%  function ELLIPSE_POINTS and has the following fields:
%   - isa = 'ellipse'      -- object type, see CHFUN
%   - type = [1 1 ?]       -- canonical=1, covar=1, polar=?
%   - A = 1/(2*(1-rho^2)*SIGx^2) -- coefficient in front of (X-Xc)^2
%   - B = (2*rho)/(-2*(1-rho^2)*SIGx*SIGy) -- coeff in f.of (X-Xc)(Y-Yc)
%   - C = 1/(2*(1-rho^2)*SIGy^2) -- coefficient in front of (Y-Yc)^2
%   - Xc  -- abscissa of the center of the ellipse
%   - Yc  -- ordinate of the center of the ellipse
%   - free=-1 -- default free coefficient.  Must always be negative.
%   %% The following fields are copied over:
%   - SIGx -- std.dev along the X axis
%   - SIGy -- std.dev along the Y axis
%   - rho  -- correlation coefficient
%
%  No error checking. It is assumed COVXY is symmetric, semidefinite...
%
%  @@ BUG:  The Gaussian integral is implemented without the factor  @@
%  @@ BUG:    1/(2*pi*SIGx*SIGy*sqrt(1-rho^2))                       @@
%  @@ BUG:  Thus, the confid.level does not equal Pcrit. Or does it? @@
%
%  Example (??% contour of a bivariate normal distribution):
%    X=randn(1000,1);Y=randn(1000,1);Y=(X+2*Y)/3+1;cov(X,Y)
%    d = covar2ellipse(cov(X,Y),mean(X),mean(Y))
%    [ex,ey]=ellipse_points(d); plot(X,Y,'b.',ex,ey,'r-');axis equal;
%    h=-chfun(d,X,Y);n=sum(h>0);title([int2str(n) ' inside points']);
%
%  See also ELLIPTIC_CI, ELLIPSE_POINTS, ELLIPSE_DESCR, COV, MVNPDF.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 0.9 $  $Date: 2006/06/13 20:15 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Handle the input arguments
xc_dflt = 0 ;
yc_dflt = 0 ;
free_dflt = -1 ;   % must be negative

if (isnumeric(arg1))            % covariance matrix
   type = [0 1 0] ;             % canonical=0, covar=1, polar=0
   SIGx = sqrt(arg1(1,1)) ;
   SIGy = sqrt(arg1(2,2)) ;
   rho = arg1(1,2) / (SIGx*SIGy) ;
   if  (nargin<2)  xc = xc_dflt ; end
   if  (nargin<3)  yc = yc_dflt ; end
   free = free_dflt ;
elseif (isstruct(arg1))         % DESCR structure
   if (isfield(arg1,'type'))  type = arg1.type ; else type = [0 1 0] ; end
   SIGx = arg1.SIGx ;
   SIGy = arg1.SIGy ;
   rho = arg1.rho ;
   if (isfield(arg1,'Xc'))  xc = arg1.Xc ;  else xc = xc_dflt ; end
   if (isfield(arg1,'Yc'))  yc = arg1.Yc ;  else yc = yc_dflt ; end
   if (isfield(arg1,'free')) free=arg1.free; else free=free_dflt; end
   descr = arg1 ;   % carry over the polar fields (if any)
else
   error('ARG1 must be a covariance matrix or descrSIGMA struct.') ;
end

%-- The real conversion
type(1) = 1 ;            % canonical=1, covar=1, polar=?
II_rho2 = 2 * (1-rho^2) ;
if (II_rho2 < 1e-12)
    error('Perfectly correlated variables do not define an ellipse.') ;
end

descr.isa = 'ellipse' ;
descr.type = type ;
descr.A = 1 / (II_rho2 * SIGx^2) ;
descr.B = (-2*rho) / (II_rho2 * SIGx * SIGy) ;
descr.C = 1 / (II_rho2 * SIGy^2) ;
descr.Xc = xc ;
descr.Yc = yc ;
descr.free = free ;
descr.SIGx = SIGx ;
descr.SIGy = SIGy ;
descr.rho = rho ;

%--- Return DESCR
%%%%% End of COVAR2ELLIPSE.M
