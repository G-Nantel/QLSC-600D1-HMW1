function [X,Y] = ellipse_points(arg1,b,c,xc,yc,n)

%ELLIPSE_POINTS -- A set of points satisfying AX^2+BXY+CY^2=1.
%
%  [X,Y] = ellipse_points(a,b,c)
%  [X,Y] = ellipse_points(a,b,c,xc,yc)
%  [X,Y] = ellipse_points(a,b,c,xc,yc,n)
%  [X,Y] = ellipse_points(descr)
%  [X,Y] = ellipse_points(descr,n)
%
%  Returns a set of points [X,Y] satisfying the quadratic equation
%
%    A*(X-Xc).^2 + B*(X-Xc).*(Y-Yc) + C*(Y-Yc).^2 == 1
%
%  where the coefficients A,B,C must satisfy A>0, C>0, B^2<4AC.
%  The center coordinates Xc and Yc can be omitted (default=0).
%  N specifies the number of points generated for each branch (deflt=100).
%  The total number of points is 2N+1, beginning at (Xmin,Ylow) and going
%  to (Xmax,Ylow) to (Xmax,Yhigh) to (Xmin,Yhigh) to (Xmin,Ylow).
%  Alternatively, the coefficients may be passed as a structure DESCR.
%
%  Example:
%    [x,y] = ellipse_points(1,1,1) ; plot(x,y,'.-');axis equal;grid on;
%
%  See also ELLIPSE_DESCR, COVAR2ELLIPSE, ELLIPTIC_CI, CHFUN, PLOT.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2003/07/16 12:10 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Handle the input arguments
if (isnumeric(arg1))        % A,B,C format
   a = arg1 ;
   if  (nargin<4)  xc = 0 ; end
   if  (nargin<5)  yc = 0 ; end
   if  (nargin<6)  n = 100; end
elseif (isstruct(arg1))     % DESCR format
   if  (nargin==1) n = 100; else n = b ; end
   a = arg1.A ;
   b = arg1.B ;
   c = arg1.C ;
   if (isfield(arg1,'Xc'))  xc = arg1.Xc ;  else xc = 0 ; end
   if (isfield(arg1,'Yc'))  yc = arg1.Yc ;  else yc = 0 ; end
   if (isfield(arg1,'free'))   % right-hand side is not 1.0
      rhs = -arg1.free ;
      if (rhs<0)  error('The free coefficient should be negative.') ; end
      a = a/rhs ; b = b/rhs ; c = c/rhs ;   % canonicalize
   end
else
   error('ARG1 must be either coefficient A or a structure DESCR.') ;
end

%-- Check the constraints
d = 4*a*c - b^2 ;    % must be >0
if (a<=0 || c<=0 || d<=0)
    disp([a b c d]) ;
   error('Constraint violation. A>0, C>0, B^2<4*A*C for an ellipse.') ;
end

%-- Calculate the range of X, ignoring Xc for the moment
Xmin = -2*sqrt(c/d) ; Xmax = -Xmin ;
X = [Xmin:(Xmax-Xmin)/n:Xmax]' ;     % n+1 by 1

%-- Calculate the low and high arc of the elllipse
sqrtR2X2 = real(sqrt(4*c - d*X.^2)) ;
Ylo = (-b*X - sqrtR2X2) / (2*c) ;
Yhi = (-b*X + sqrtR2X2) / (2*c) ;

%-- Stitch up the full ellipse, (n+1)+n points total
Xhi = flipud(X(1:n)) ;     % note that X(n+1)=Xmax is omitted
Yhi = flipud(Yhi(1:n)) ;   % reverse order so that they plot properly
X = [X   ; Xhi] ;      % [2n+1,1]
Y = [Ylo ; Yhi] ;      % [2n+1,1]

%-- Add the center and return
X = X + xc ;
Y = Y + yc ;

%--- Return X and Y
%%%%% End of ELLIPSE_POINTS.M
