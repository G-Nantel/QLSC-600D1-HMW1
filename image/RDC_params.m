function  Rparams = RDC_params(Rparams,deluxep)

%RDC_PARAMS --  Default params for random-dot cinematograms
%   
%  Rparams = RDC_params
%  Rparams = RDC_params(seed_params)
%  Rparams = RDC_params(seed_params,deluxep)
%  Rparams = RDC_params([],deluxep)
%
%  SEED_PARAMS is a structure supplying values for some of the fields.
%  The remaining fields are filled in with default values.
%  Also, many auxiliary fields are derived from the main fields.
%  When DELUXEP=0 (=default), Rparams are designed for use with the
%  ordinary RENDER_RDC.  Set DELUXEP=1 to use RENDER_RDC_DELUXE instead.
%  The two versions are *not* compatible.
%
%  NOTE: The fields are not independent. If you overwrite some of them,
%  NOTE: make sure to propagate the changes: Rparams=RDC_params(Rparams)
%
%  Fields:
%        deluxep: 0         -- set to 1 to use RENDER_RDC_DELUXE
%       img_size: [255 255] -- in pixels, must be odd numbers
%        pix_deg: 72        -- pixels per degree of visual angle
%     msec_frame: 13.333    -- miliseconds per frame (75Hz)
%       duration: 30        -- total number of frames
%       aperture: 3.4       -- diameter, degrees of visual angle
%         N_dots: 100       -- total number of dots within the aperture
%        N_coher: 0         -- number of coherently moving dots
%      direction: 0         -- direction of coh. motion [deg from vert]
%      dot_speed: 10        -- degrees per second
%       dot_diam: 0.10      -- dot diameter, 6 arcmin
%     wraparound: 1         -- 0=none, 1=flip_before=dflt, 2=flip_after
%     anti_alias: 7         -- expansion factor for a.a. rendering
%     [multiple auxiliary fields used by MAKE_RDC_SPEC and RENDER_RDC]
%
%  Typical usage:
%    R = RDC_params ; R.<some_field> = xxx ; R = RDC_params(R) ;
%    RDC_spec = make_RDC_spec(R,...) ; RDC = render_RDC(R,RDC_spec) ;
%
%  Reference:
%    Britten, K., Shadlen, M., Newsome, W., & Movshon, J. (1992).
%    The analysis of visual motion: A comparison of neuronal and
%    psychophysical performance. _J of Neuroscience_, 12 (12), 4745-4765.
%
%  See also MAKE_RDC_SPEC, RENDER_RDC, RENDER_RDC_DELUXE, RDC_MOVIE.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 2.0 $  $Date: 2007-12-05 $
%
% Part of the utils toolbox version 1.2 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2008, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

% 2.0     2007-12-05  ap -- Switch to the Newsome algorithm
% 1.1.1   2007-05-04  ap -- Make sure ji_origin is an integer

if (nargin<2) ; deluxep = 0 ; end
if (nargin<1)
	Rparams = struct('deluxep',0) ;
elseif (isempty(Rparams))
    Rparams = struct('deluxep',deluxep) ; 
end

%%-- Main fields
if (nargin==2)                      % deluxep explicitly supplied
    Rparams.deluxep = deluxep ;
elseif (isfield(Rparams,'deluxep')) % supplied by the seed params
    deluxep = Rparams.deluxep ;
else                                % incomplete seed params
    Rparams.deluxep = 0 ;           % default
end
if (~isfield(Rparams,'img_size'))
   Rparams.img_size = [255 255] ;   % pixels
end
sz = Rparams.img_size ;
if (any(mod(sz,2)==0))
    warning('Converting Rparams.img_size to the nearest odd numbers.') ;
    sz = 2.*floor(sz./2) + 1 ;
    Rparams.img_size = sz ;
end
if (~isfield(Rparams,'pix_deg'))
  Rparams.pix_deg = 72 ;           % pixels per 1 degree of visual angle
end
pix_deg = Rparams.pix_deg ; 
if (~isfield(Rparams,'msec_frame'))
  Rparams.msec_frame = 1000/75 ;   % 13.33 milliseconds per frame at 75 Hz
end
if (~isfield(Rparams,'duration'))
  Rparams.duration = 30 ;          % total number of frames
end
if (~isfield(Rparams,'aperture'))
  Rparams.aperture = 3.4 ;         % diameter, degrees of visual angle
end
if (~isfield(Rparams,'N_dots'))
  Rparams.N_dots = 100 ;           % total number of dots within aperture
end
if (~isfield(Rparams,'N_coher'))
  Rparams.N_coher = 0 ;            % number of coherently moving dots
end
if (~isfield(Rparams,'direction'))
  Rparams.direction = 0 ;          % direction of coherent motion
end
if (~isfield(Rparams,'dot_speed'))
  Rparams.dot_speed = 10 ;         % degrees per second
end
if (~isfield(Rparams,'dot_diam'))
  Rparams.dot_diam = 0.10 ;        % dot diameter, degrees vis. angle
end
if (~isfield(Rparams,'wraparound'))
  Rparams.wraparound = 1 ;         % 0=none, 1=flip_before, 2=flip_after
end
if (min(sz)<ceil(Rparams.aperture*pix_deg)+ceil(Rparams.dot_diam*pix_deg)+1)
    warning('RDC image size too small for this aperture  resolution.');
end
if (~isfield(Rparams,'anti_alias'))% expansion factor for anti-aliased
  Rparams.anti_alias = 7 ;         % rendering of the dots on the canvas
end
if (mod(Rparams.anti_alias,2)==0)  % RENDER_RDC1 requires an odd number
    warning('Converting Rparams.anti_alias to the nearest odd number.') ;
    Rparams.anti_alias = Rparams.anti_alias + 1 ;
end

%%-- Auxiliary field used by MAKE_RDC_SPEC
%- distance covered per frame, degrees of visual angle
Rparams.displacement = (Rparams.dot_speed/1000) * Rparams.msec_frame ;

%%-- Auxiliary fields used by RENDER_RDC and various plotting functions
%- Coarse grid, degrees of visual angle. For plotting, etc.
%  Cartesian coordinates centered in the middle of the image
Rparams.x = make_grid(sz(2),1/pix_deg) ;
Rparams.y = make_grid(sz(1),1/pix_deg)' ;

%- Conversion from XY (degree) to IJ (pixel) coordinate origins.
%  Usage:  ji = xy.*Rparams.pix_deg + Rparams.ji_origin ;     % [2x1]
%  Usage:  xy = (ji-Rparams.ji_origin) ./ Rparams.pix_deg ;   % [2x1]
%  ji_origin consists of two integers because img_size is two odd numbers
%  This fact is used to optimize code in RENDER_RDC and RENDER_RDC_DELUXE.
ji_origin = 1 - pix_deg.*[Rparams.x(1) Rparams.y(1)] ;
if (abs(ji_origin-round(ji_origin))>.001)
    warning(sprintf(...
      'JI_ORIGIN is not an integer [%.3f %.3f]. Rounding...',ji_origin)) ;
end
Rparams.ji_origin = round(ji_origin) ;

%- Precompute anti-aliasing support information
Rparams.AAparams = render_RDC_aux(Rparams) ;

%--- Return RPARAMS
%%%%% End of file RDC_PARAMS.M
