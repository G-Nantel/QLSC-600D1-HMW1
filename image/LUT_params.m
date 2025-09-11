function  params = LUT_params(seed_params)

%LUT_PARAMS --  Default lookup-table parameters for MAKE_LINEAR_LUT.
%   
%  PARAMS = LUT_PARAMS
%  PARAMS = LUT_PARAMS(seed_params)
%
%  SEED_PARAMS is a structure supplying values for some of the fields.
%  The remaining fields are filled in with default values.
%
%  Example: params = LUT_params
%    params =
%        gamma: 1.95     % the power of the monitor's "gamma function"
%       BRstep: 24       % hardwired characteristic of the Blue+Red circuit
%     contrast: 1.0      % proportion of the full dynamic range
%       domain: [0 255]  % which entries in the LUT we're talking about
%   S_contrast: 0.25     % contrast for signals in "split LUTs"
%     S_domain: [1 127]  % domain for signals in "split LUTs"
%   N_contrast: 1.0      % contrast for background noise in "split LUTs"
%     N_domain: [128 255]  % domain for background noise in "split LUTs"
%
%  See also MAKE_LINEAR_LUT, MAKE_SPLIT_LUT.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/05 20:40 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%---  Decipher SPEC
if (nargin==0)                   % default
   params = struct('gamma',1.95) ;       % as calibrated on 10-30-01
elseif (isstruct(seed_params))   % structure
  params = seed_params ;         % copy existing slots
else
  error('SEED_PARAMS must be a structure.') ;
end

%--- Fill-in missing slots
if (~isfield(params,'gamma'))
  params.gamma = 1.95 ;
end
if (~isfield(params,'BRstep'))
  params.BRstep = 24 ;       % characteristic of the Blue+Red circuit
end
if (~isfield(params,'contrast'))
  params.contrast = 1.0 ;    % proportion of the full dynamic range
end
if (~isfield(params,'domain'))
  params.domain = [0 255] ;  % which entries in the LUT we're talking about
end
if (~isfield(params,'S_contrast'))
  params.S_contrast = 0.25 ; % contrast for background noisein "split LUTs"
end
if (~isfield(params,'S_domain'))
  params.S_domain = [1 127] ;  % domain for signals in "split LUTs"
end
if (~isfield(params,'N_contrast'))
  params.N_contrast = 1.0 ;  % contrast for noise in "split LUTs"
end
if (~isfield(params,'N_domain'))
  params.N_domain = [128 255] ;  % domain for noise in "split LUTs"
end

%--- Return PARAMS
%%%%% End of file LUT_PARAMS.M
