% Image-Processing Utilities Toolbox
% Version 1.4  2007-12-06
%
% Some of the utilities below add a layer of abstraction around Matlab's
% FFT2 routine. Others are designed to work with PsychToolbox's RUSH
% utility (http://psychtoolbox.org/). There are also some one-liners.
%
% Gabor patches and other psychophysical displays:
%   gabor        - Sinusoidal grating under a Gaussian envelope.
%   grating      - Sinusoidal grating (grayscale image).
%   slant        - Sloping plane through the origin.
%   gabor_params - Specification of a Gabor patch or sinusoidal grating.
%
% Filtering in the frequency domain:
%   filter_img   - Filter a grayscale image in the frequency domain.
%   fftmesh      - Fx and Fy domains arranged to dovetail with FFT2.
%   filtnoise    - Gaussian noise filtered through a user-supplied filter.
%   butterworth1 - One-dimensional Butterworth lowpass filter of order 1.
%   butterworth2 - Wedge-like Butterworth lowpass filter in two dimensions.
%
% Elliptical confidence regions:
%   ellipse_points - A set of points satisfying AX^2+BXY+CY^2=1.
%   ellipse_descr  - Describe an ellipse in three equivalent ways
%   covar2ellipse  - Covariance matrix --> ellipse coefficients.
%   elliptic_CI  - Elliptic confidence region for bivariate Gaussian data.
%   chfun        - Evaluates a supplied characteristic function.
%
% Miscellaneous:
%   cart2pol2    - Transform an image from Cartesian to polar coordinates.
%   pol2cart2    - Transform an image from polar to Cartesian coordinates.
%   imagesc1     - Scale data and display as a gray image with colorbar.
%   coldhot      - Default Leabra color map  [lblue dblue grey red yellow]
%   reppix       - Replicates pixels in an image.
%   mosaic       - An image of random black and white tiles.
%
% MovieStruct movies:
%   MovieStructDemo - Demo of PsychToolbox movies and "movieStructs".
%   MakeMovieStruct - Make a movieStruct -- the skeleton of a movie.
%   LoadMovieStruct - Load images into movieStruct's off-screen buffers.
%   PlayMovieStruct - RUSHes the movie loaded in a movieStruct.
%   CloneMovieStruct - Clone a movieStruct to another location or sequence.
%   UnrollMovieLoop - Make a RUSHable string of SCREEN calls.
%
% Random-dot cinematograms (v. 2.0):
%   RDC_params      - Default params for random-dot cinematograms
%   make_RDC_spec   - Frame-by-frame specification of dot locations
%   render_RDC      - Render a RDC_spec as a 3D grayscale bitmap
%   render_RDC_deluxe - High-precision render_RDC, ~4 times slower
%   RDC_movie       - Animation of a RDC as a Matlab movie
%
% Lookup table manipulation:
%   make_linear_LUT - Calibrated LUT with equal-luminance intervals.
%   make_split_LUT  - LUT with two parts with different resolution.
%   LUT_params      - Default parameters for MAKE_xxx_LUT.
%   NewCalibrator   - Psychophysical estimation of the monitor's GAMMA.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.4 $  $Date: 2007-12-06 $
%
% Part of the utils toolbox version 1.2 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2008, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m
