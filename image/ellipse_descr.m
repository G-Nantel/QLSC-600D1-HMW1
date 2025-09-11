function  descr = ellipse_descr(descr)

%ELLIPSE_DESCR -- Describe an ellipse in three equivalent ways
%
%  full_descr = ellipse_descr(partial_descr)
%  full_descr = ellipse_descr
%
%  PARTIAL_DESCR must be a structure with the following fields:
%   - isa = 'ellipse'
%   - type  -- a 1x3 vector of 0s and 1s: [canonicalp, covar, polar]
%   - Xc  -- abscissa of the center of the ellipse
%   - Yc  -- ordinate of the center of the ellipse
%   - free -- additive coefficient. Must always be negative (=-rhs).
%   % The remaining fields must define the ellipse according to TYPE
%   % If more than one types are defined, canonical > covar > polar.
%  When used with no arguments, ELLIPSE_DESCR generates a default
%  descriptor template specifying a unit circle at the origin.
%
%  The function fills in the missing slots to make a universal descriptor:
%   - type = [1 1 1]  -- all three possible types are now instantiated
%   % canonical fields (used by ELLIPSE_POINTS):
%   - A    -- coefficient in front of (X-Xc)^2
%   - B    -- coefficient in front of (X-Xc)(Y-Yc)
%   - C    -- coefficient in front of (Y-Yc)^2
%   % covariance fields:
%   - SIGx -- std.dev along the X axis
%   - SIGy -- std.dev along the Y axis
%   - rho  -- correlation coefficient
%   % polar fields:
%   - R1   -- long semi-axis
%   - R2   -- short semi-axis
%   - theta - orientation of the long semiaxis (radians from horizontal)
%
%  Example: Plot an ellipse with R1:R2=3:1, tilted 30* from horizontal:
%   d=ellipse_descr;d.type=[0 0 1];d.R1=3;d.R2=1;d.theta=30*(pi/180);
%   d=ellipse_descr(d);[x,y]=ellipse_points(d);plot(x,y,'.-');axis equal;
%
%  See also ELLIPSE_POINTS, COVAR2ELLIPSE, ELLIPTIC_CI, CHFUN.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.1 $  $Date: 2006/06/12 13:15 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

if (nargin==0)                % generate a template descriptor?
    descr.isa = 'ellipse' ;
    descr.type = [1 0 0] ;
    descr.Xc = 0 ;
    descr.Yc = 0 ;
    descr.free = -1 ;
    descr.A = 1 ;
    descr.B = 0 ;
    descr.C = 1 ;
end

canonp = descr.type(1) ;
covarp = ~canonp & descr.type(2) ;   % canonical overrides covariance
polarp = ~canonp & descr.type(3) ;   % canonical overrides polar

% Convert from a non-canonical to canonical type
if (covarp)
    SIGx = descr.SIGx ;
    SIGy = descr.SIGy ;
    rho = descr.rho ;
    II_rho2 = 2 * (1-rho^2) ;
    if (II_rho2 < 1e-12)
        error('Perfectly correlated variables do not define an ellipse.') ;
    end
    descr.A = 1 / (II_rho2 * SIGx^2) ;
    descr.B = (-2*rho) / (II_rho2 * SIGx * SIGy) ;
    descr.C = 1 / (II_rho2 * SIGy^2) ;
elseif (polarp)   % covariance overrides polar because of the ELSEif
    R1sq = (descr.R1)^2 ;
    R2sq = (descr.R2)^2 ;
    sin2th = sin(descr.theta)^2 ;
    cos2th = cos(descr.theta)^2 ;
    two_sc = 2*sin(descr.theta)*cos(descr.theta) ;
    descr.A = cos2th/R1sq + sin2th/R2sq ;
    descr.B = two_sc/R1sq - two_sc/R2sq ;
    descr.C = sin2th/R1sq + cos2th/R2sq ;
end

% It is now guaranteed that the canonical coefficients are defined
A = descr.A ;    % A > 0
B = descr.B ;    % B^2 < 4*A*C
C = descr.C ;    % C > 0

%-- Check the conic-sectin constraints for ellipse
if (A<=0 | C<=0 | B^2>=4*A*C)   % Matlab 5.2 doesn't support || operator
   error('Constraint violation. A>0, C>0, B^2<4AC for an ellipse.') ;
end

% Convert from canonical to covariance
if (~covarp)
    if (B==0)
        rho = 0 ;
    else
        rho = -B / (2*sqrt(abs(A*C))) ;    % abs(rho) < 1
    end
    II_rho2 = 2 * (1-rho^2) ;
    descr.SIGx = 1 / sqrt(A*II_rho2) ;
    descr.SIGy = 1 / sqrt(C*II_rho2) ;
    descr.rho = rho ;
end

% Convert from canonical to polar
if (~polarp)
    %D = sqrt((C-A)^2+4*B^2) ;  % http://mathworld.wolfram.com/Ellipse.html
    %R1 = sqrt(2/(A+C-D)) ;     % doesn't quite work
    %R2 = sqrt(2/(A+C+D)) ;
    theta = atan2(-B,C-A)/2 ;   % -pi/2 <= theta <= pi/2
    if (A==C)
        R1 = sqrt(2/(A+C-abs(B))) ;
        R2 = sqrt(2/(A+C+abs(B))) ;
    else
        sin2th = sin(theta)^2 ;
        cos2th = cos(theta)^2 ;
        R1 = sqrt(abs((cos2th-sin2th)/(A*cos2th-C*sin2th))) ;
        R2 = sqrt(abs((sin2th-cos2th)/(A*sin2th-C*cos2th))) ;
    end
    descr.R1 = R1 ;
    descr.R2 = R2 ;
    descr.theta = theta ;
end

descr.type = [1 1 1] ;

%--- Return DESCR
%%%%% End of ELLIPSE_DESCR.M
