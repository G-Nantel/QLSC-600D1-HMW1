MvStructREADME.txt  -- 26 Jan 2005

This archive contains version 1.0 of the MovieStruct utilities.
This version was used in Perceptual Learning Experiments 1 and 2
(see PLExp1 and PLExp2) in 2002 and 2003 and it worked without
a glitch.

Then some changes were introduced to UnrollMovieLoop to address
a problem that appeared with a new 10-bit Radeon 8500 video card.
PlayMovieStruct misses a frame on about 2-3% of the presentations.
In an effort to speed things up and fix the problem, Alex looked
at the PsychToolbox discussion forum.  In message 392, Mar 10, 2001 
Dennis Pelli wrote:
  ...On most computers today copywindow will run faster if
  you OMIT 'srcCopyQuickly'...

The current revision (1.1) of UnrollMovieLoop does just that.
Still, the old version is hereby archived to insure maximum 
replicability of PL Experiments 1 and 2.

%%%%%%%%  Excerpts from the old CONTENTS.M file

% Version 1.0  09-Dec-2001
%
% MovieStruct movies:
%   MovieStructDemo - Demo of PsychToolbox movies and "movieStructs".
%   MakeMovieStruct - Make a movieStruct -- the skeleton of a movie.
%   LoadMovieStruct - Load images into movieStruct's off-screen buffers.
%   PlayMovieStruct - RUSHes the movie loaded in a movieStruct.
%   CloneMovieStruct - Clone a movieStruct to another location or sequence.
%   UnrollMovieLoop - Make a RUSHable string of SCREEN calls.
%
% Lookup table manipulation:
%   make_linear_LUT - Calibrated LUT with equal-luminance intervals.
%   make_split_LUT  - LUT with two parts with different resolution.
%   LUT_params      - Default parameters for MAKE_xxx_LUT.
%   NewCalibrator   - Psychophysical estimation of the monitor's GAMMA.

% Original coding by Alexander Petrov, University of California, Irvine
% apetrov@uci.edu    http://www.socsci.uci.edu/~apetrov/
