function  h = chfun(descr,X,Y)

%CHFUN -- Evaluate the characteristic function DESCR on points X,Y.
%
%  h = chfun(descr,X,Y)
%
%  X and Y must be numerical arrays.  size(X)=size(Y)=size(H)
%  DESCR must be a structure. Supported 'isa' types are:
%   * ellipse -- two descriptor formats are supported
%      -- ABC format: fields 'A','B','C', &optional 'Xc','Yc', 'free'
%      -- SIGMA format: fields 'SIGx','SIGy','rho' (or 'covXY'), ...
%      See ELLIPSE_POINTS, COVAR2ELLIPSE, ELLIPTIC_CI.
%   * <no other curves yet>
%
%  Example (??% contour of a bivariate normal distribution):
%    N=10000 ; X = randn(N,1) ; Y = randn(N,1) ; Y = 1+(X+3*Y)/5;
%    d = elliptic_CI(X,Y,0.90) ; h = -chfun(d,X,Y) ; 
%    n = sum(h>0)  % Number of inside points, see COVAR2ELLIPSE.
%
%  See also ELLIPSE_POINTS, PLOT.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2006/06/13 15:10 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%--  Dispatch on DESCR type
switch  lower(descr.isa)
case 'ellipse'
   if (descr.type(1))       % canonical format
      h = ellipse_ABC(descr,X,Y) ;
   elseif  (descr.type(2))  % covariance format
      h = ellipse_SIGMA(descr,X,Y) ;
   else
      error('Unsupported descriptor format for type ''ellipse''.') ;
   end
otherwise
   error(['Unsupported type: ''',descr.isa,'''.']) ;
end

%--- Return H
%%%% End of the main function

%%%%%%%%%%%%%%%%%%%%%%%  METHODS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  h = ellipse_ABC(descr,X,Y)
% A(X-Xc)^2 + B(X-Xc)(Y-Yc) + C(Y-Yc)^2 + F

A = descr.A ; B = descr.B ; C = descr.C ;
if (isfield(descr,'Xc'))  Xc = descr.Xc ; else Xc = 0 ; end
if (isfield(descr,'Yc'))  Yc = descr.Yc ; else Yc = 0 ; end
if (isfield(descr,'free')) F = descr.free ; else F = 0 ; end

x = X-Xc ; y = Y-Yc ;
h = A*x.^2 + B*x.*y + C*y.^2 + F ;
%
%%% End of ELLIPSE_ABC method   --------------------------------------


function  h = ellipse_SIGMA(descr,X,Y)
% (-1/2(1-rho^2)) * [(X/SIGx)^2 - 2rho(X/SIGx)(Y/SIGy) + (Y/SIGy)^2]

SIGx = descr.SIGx ; SIGy = descr.SIGy ;
if (isfield(descr,'rho'))
   rho = descr.rho ;
else   % COVXY must be supplied instead
   rho = descr.covXY / (SIGx*SIGy) ;
end
if (isfield(descr,'Xc'))  Xc = descr.Xc ; else Xc = 0 ; end
if (isfield(descr,'Yc'))  Yc = descr.Yc ; else Yc = 0 ; end
if (isfield(descr,'free')) F = descr.free ; else F = 0 ; end

x = (X-Xc) ./ SIGx ;
y = (Y-Yc) ./ SIGy ;
h = (x.^2 - (2*rho)*x.*y + y.^2) ./ (-2*(1-rho^2)) + F ;
%
%%% End of ELLIPSE_SIGMA method

%%%%% End of file CHFUN.M
