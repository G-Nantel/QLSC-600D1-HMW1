function  [LUT,grayIdx] = make_lin10bit_LUT(spec)

%MAKE_LIN10BIT_LUT -- Calibrated 10-bit linear lookup table.
%   
%  LUT = make_lin10bit_LUT(gamma)
%  LUT = make_lin10bit_LUT(params)
%  [LUT,grayIdx] = make_lin10bit_LUT(...)
%
%  The input argument must be either a number or a structure with fields
%  'gamma', 'levels', 'contrast', and 'domain' (see also LUT_PARAMS).
%  When a numeric argument is used it specifies GAMMA; the other three
%  fields default to levels=1023, contrast=1, and domain=[0 255].
%  (Note that no 'BRstep' field is needed, unlike MAKE_LINEAR_LUT.)
%  LUT is a lookup table: a 256x3 matrix of R-G-B control bytes.
%  The three columns (RGB) are identical, yielding achromatic grays.
%  GRAYIDX is the index of the LUT entry producing mid-gray (0.5) color.
%
%  When you prepare a grayscale image (a uint8 matrix), each pixel is
%  encoded with one byte. This byte does not control the monitor's
%  electronic beam directly. Instead, it is an index into a "lookup table
%  (LUT)."  The LUT values then pass through digital-to-analog converters
%  to produce "drive voltages" for the three guns of a color CRT.
%  The problem is that due to the physics of phosphor luminescence and
%  so foth the actual luminance of the light emitted by the screen is a
%  non-linear (accelerating) function of drive voltage.  Various tricks
%  are used to compensate for this non-linearity. The present function is
%  designed to dovetail with the setup in our lab, described as follows:
%
%  A color (as opposed to monochrome) monitor is used but the R, G, and B
%  guns are always driven with equal voltage to produce levels of gray.
%  (It may have pinkish or bluish or greenish tint but that is close
%  enough to achromatic gray for our purposes.)  The video card uses a
%  10-bit lookup table with 256 entries. Thus, it is possible to specify
%  256 distinct gray levels, quantized on a grid with step=1/1023 of the
%  total luminance range achievable on the monitor.
%  (See MAKE_LINEAR_LUT.M for an alternative 8-bit setup.)
%
%  Now for the non-linearity. The relationship between the drive voltage
%  V and the output luminance L is called the monitor's "gamma function".
%  It is determined experimentally and there are several competing
%  mathematical formulations (see FITGAMMA in PsychToolbox/PsychGamma).
%  In our lab, we assume it is a simple power function of the form:
%    L = L0 * V^gamma   , where L0 is the background luminance.
%  GAMMA is a free parameter measured experimentally for each monitor.
%  (The routines G10CALIBRATOR and G10CALIBRATORGRAY estimate GAMMA via
%  a psychophysical matching procedure.) Typical values for GAMMA are
%  between 1.2 and 2.5.
%
%  So, our strategy is to arrange the LUT according to the INVERSE GAMMA
%  function: V = (L/L0)^(1/gamma).  In this way, the LUT compresses the
%  intensities at the high end of the scale whereas the phosphorus of
%  the monitor expands them by the same amount. The net result (hopefully)
%  is a linear mapping from the intensity values specified in your
%  grayscale image in memory and the actual physical luminance of the
%  pixels on the screen.
%
%  The two remaining fields in the PARAMS structure--'contrast' and
%  'domain'--are better left at their default values of 1.0 and [0 255],
%  respectively. They are provided so that MAKE_LIN10BIT_LUT can serve
%  as a building block for MAKE_SP10BIT_LUT. See there for details.
%
%  Ten-bit lookup tables must be installed in Psych Toolbox programs
%  via a call of the form (SCREEN is the PsychToolbox dispatcher fun):
%    err=SCREEN(winPtr,'SetClut',LUT,[0 0 0],10)
%
%  References:
%    Brainard, D. (1997). The Psychophysics Toolbox. Spatial Vision,
%      10, 433-436. [http://psychtoolbox.org/tutorial.html]
%    Pelli, D. & Zhang, L. (1991). Accurate control of contrast on
%      microcomputer displays. Vision Research, 31, 1337-1350.
%
%  Example:
%    [LUT,grayIdx] = make_lin10bit_LUT(myGAMMA) ;
%    SCREEN(winPtr,'SetClut',LUT,[0 0 0],10) ;
%    SCREEN(winPtr,'FillRect',grayIdx) ;
%
%  See also MAKE_SP10BIT_LUT, MAKE_LINEAR_LUT, LUT_PARAMS, G10CALIBRATOR.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 0.8 $  $Date: 2004/02/24 15:15 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m


error('Under construction...') ;


@@@ The code below is from MAKE_LINEAR_LUT.M:
%-- Decipher params
if (isstruct(spec))         % PARAMS structure?
   gamma = spec.gamma ;
   BRstep = spec.BRstep ;
   contrast = spec.contrast ;
   domain = spec.domain ;
elseif (isnumeric(spec))    % Raw GAMMA value?
   gamma = spec ;
   BRstep = 24 ;       % default
   contrast = 1.0 ;    % default
   domain = [0 255] ;  % default
else
   error('The argument must be either a number or a structure.') ;
end

%-- Calculate target voltage according to the inverse gamma function
offset = domain(1) ;
N_intervals = domain(2) - domain(1) ;
N_entries = N_intervals + 1 ;
halfpoint = floor(1+N_entries/2) ;
idx = [1:N_entries]' ;
span = 2*max(halfpoint-1,N_entries-halfpoint) ;

luminance = 0.500 + (idx - halfpoint) .* (contrast/span) ;
target = 255 * luminance.^(1/gamma) ;    % continuous between 0 and 255

%-- Discretize TARGET: integer part in Red + fractional part in Blue.
B = floor(target +0.5/BRstep) ;
R = round((target-B).*BRstep) ;   % in 1/24 increments

%-- Put everything together
LUT = [[0:255]' zeros(256,1) [0:255]'] ;   % DOMAIN may cover only part
LUT(idx+offset,1) = R ;
LUT(idx+offset,2) = zeros(N_entries,1) ;   % leave Green alone
LUT(idx+offset,3) = B ;
grayIdx = halfpoint + offset - 1 ;   % all indices assumed to start at 0

%--- Return LUT and possibly GRAYIDX
%%%%% End of file MAKE_LIN10BIT_LUT.M
