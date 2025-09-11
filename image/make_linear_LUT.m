function  [LUT,grayIdx] = make_linear_LUT(spec)

%MAKE_LINEAR_LUT -- Calibrated lookup table with equal-luminance intervals.
%   
%  LUT = make_linear_LUT(gamma)
%  LUT = make_linear_LUT(params)
%  [LUT,grayIdx] = make_linear_LUT(...)
%
%  The input argument must be either a number or a structure with fields
%  'gamma', 'BRstep', 'contrast', and 'domain' (see also LUT_PARAMS).
%  When a numeric argument is used it specifies GAMMA; the other three
%  fields default to BRstep=24, contrast=1, and domain=[0 255].
%  LUT is a lookup table: a 256x3 matrix of R-G-B control bytes.
%  GRAYIDX is the index of the LUT entry producing gray (0.5) color.
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
%  A monochrome (as opposed to color) monitor is used. A special circuit
%  combines the red and blue channels into a single drive voltage for
%  the monochrome CRT. Moreover, the blue channel is added with weight 1,
%  whereas the red channel is added with weight 1/24. Thus the minimal
%  achievable increment is (1/24)*(1/256) instead of simply (1/256).
%  See Pelli & Zhang (1991) for details. The parameter BRSTEP defines
%  the intensity of the blue channel relative to the red channel. (Our
%  circuit is hardwired for BSTEP=24; hence the default in LUT_PARAMS).
%  The green channel is left alone because it carries synchronization. 
%  Therefore, all entries produced by MAKE_LINEAR_LUT have the following
%  structure: the first (R) byte carries the fractional part of the 
%  desired drive voltage (with increment=1/24), the second (G) byte is
%  always zero, and the last (B) byte carries the integer part of the
%  voltage.
%
%  Now for the non-linearity. The relationship between the drive voltage
%  V and the output luminance L is called the monitor's "gamma function".
%  It is determined experimentally and there are several competing
%  mathematical formulations (see FITGAMMA in PsychToolbox/PsychGamma).
%  In our lab, we assume it is a simple power function of the form:
%    L = L0 * V^gamma   , where L0 is the background luminance.
%  GAMMA is a free parameter measured experimentally for each monitor.
%  (The routine NEWCALIBRATOR estimates GAMMA via a psychophysical
%  matching procedure.) Typical values for GAMMA are between 1.8 and 2.2.
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
%  respectively. They are provided so that MAKE_LINEAR_LUT can serve as
%  a building block for MAKE_SPLIT_LUT. See there for details.
%
%  References:
%    Brainard, D. (1997). The Psychophysics Toolbox. Spatial Vision,
%      10, 433-436. [http://psychtoolbox.org/tutorial.html]
%    Pelli, D. & Zhang, L. (1991). Accurate control of contrast on
%      microcomputer displays. Vision Research, 31, 1337-1350.
%
%  Example:
%    [LUT,grayIdx] = make_linear_LUT(myGAMMA) ;
%    SCREEN(winPtr,'SetClut',LUT) ;      % SCREEN is in the PsychToolbox
%    SCREEN(winPtr,'FillRect',grayIdx) ;
%
%  See also MAKE_SPLIT_LUT, MAKE_LIN10BIT_LUT, LUT_PARAMS, NEWCALIBRATOR.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/07 12:35 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

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
%%%%% End of file MAKE_LINEAR_LUT.M
