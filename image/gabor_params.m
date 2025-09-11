function  params = gabor_params(seed_params)

%GABOR_PARAMS --  Specification of a Gabor patch or sinusoidal grating.
%   
%  PARAMS = GABOR_PARAMS
%  PARAMS = GABOR_PARAMS(seed_params)
%
%  SEED_PARAMS is a structure supplying values for some of the fields.
%  The remaining fields are filled in with default values.
%
%  Example: params = Gabor_params
%    params =
%      amplit: 0.5      % amplitude [luminance units], min=-A,max=+A
%        freq: 0.02     % spatial frequency [cycles/pixel]
%      orient: 0        % orientation [radians]
%       phase: 1.5708   % phase [radians]
%       sigma: 25       % std.dev. of Gaussian envelope [pixels]
%
%  See also GABOR, GRATING.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/29 12:15 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%---  Decipher SPEC
if (nargin==0)                   % default
   params = struct('amplit',0.5) ;
elseif (isstruct(seed_params))   % structure
  params = seed_params ;         % copy existing slots
else
  error('SEED_PARAMS must be a structure.') ;
end

%--- Fill-in missing slots
if (~isfield(params,'amplit'))
  params.amplit = 0.5 ;      % amplitude [luminance units], min=-A,max=+A
end
if (~isfield(params,'freq'))
  params.freq = 1/50 ;       % spatial frequency [cycles/pixel]
end
if (~isfield(params,'orient'))
  params.orient = 0 ;        % orientation [radians]
end
if (~isfield(params,'phase'))
  params.phase = pi/2 ;      % phase [radians]
end
if (~isfield(params,'sigma'))
  params.sigma = 25 ;        % std.dev. of Gaussian envelope [pixels]
end

%--- Return PARAMS
%%%%% End of file GABOR_PARAMS.M
