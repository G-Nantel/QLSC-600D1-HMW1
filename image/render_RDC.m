function  RDC = render_RDC(Rparams,RDC_spec)

%RENDER_RDC -- Render a random-dot cinematogram as a sequence of images
%   
%  RDC = render_RDC(Rparams,RDC_spec)
%
%  Rparams is a structure produced by RDC_PARAMS with deluxep=false.
%  RDC_spec is a specification produced by MAKE_RDC_SPEC.
%
%  The result RDC is a 3D uint8 matrix of grayscale images or "frames".
%  Each pixel intensity is a number between 0=black and 255=white.
%  The individual dots are rendered as white discs with antialiased
%  edges against black canvas. The first matrix index spans the
%  vertical coordinate and grows upwards; the second index spans the
%  horizontal coordinate and grows rightwards. Thus, the matrix is
%  ready for screen.CopyBits (or for plotting in 'ij' axis mode).
%  The origin (0,0) is in the middle of the center pixel of the image.
%  Use RENDER_RDC_DELUXE for high-quality (but slower) rendering.
%
%  To merge RDCs, use:  RDC = max(RDC1,RDC2)
%
%  Example:
%    Rparams=RDC_params ;   % no args, or deluxep *must* be false
%    RDC_spec = make_RDC_spec(Rparams,10,30) ;  % 30 dots moving 1 o'clock
%    RDC = render_RDC(Rparams,RDC_spec) ;
%    M = RDC_movie(Rparams,RDC) ; movie(M,3) ;
%
%  See also RDC_PARAMS, MAKE_RDC_SPEC, RDC_MOVIE, RENDER_RDC_DELUXE.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.1 $  $Date: 2006/06/07 16:20 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

[N_dots t N_frames] = size(RDC_spec) ;

pix_deg = Rparams.pix_deg ;
img_size = Rparams.img_size ;
isz1 = img_size(1) ;
sidx_offset_const = Rparams.ji_origin*[isz1 1]' - isz1 ;
aa = Rparams.AAparams.aa ;  % minipixels per pixel, always an odd number
anchor_offset1 = Rparams.AAparams.anchor_offset - 1 ;
delta_offset = Rparams.AAparams.delta_offset ;
stamp_cache = Rparams.AAparams.stamp_cache ;
s2i_mult = Rparams.AAparams.s2i_mult ;
s2i_add = Rparams.AAparams.s2i_add ;
stamp_idx = Rparams.AAparams.stamp_idx ;

blank_RDC1 = uint8(zeros(img_size)) ;
%RDC = repmat(uint8(blank_RDC1),[1 1 N_frames]) ;
for t = N_frames:-1:1     % go backwards to bypass memalloc for RDC
    %- Convert degrees -> pixels
    %ji = RDC_spec(:,1:2,t).*pix_deg + ji_origin ; % degrees --> pixels
    ji = RDC_spec(:,1:2,t).*pix_deg ;  % +ji_origin into sidx_offset_const
	%- Represent each coordinate as anchor+delta
	anchor = round(ji) ;      % [N_dots x 2]
	d = (ji-anchor).*aa ;     % -.5*aa <= d <= .5*aa
	%-- Identify the index of the best-fitting "stamp"
	I = (round(d)+delta_offset) * s2i_mult ;   % in lieu of sub2ind(...)
	%- Indices of the "stamp footstep" on the canvas
	% Note that ANCHOR, like JI, has column 1=j=x and column 2=i=y
	% sidx_offset = sub2ind(img_size,anchor(:,2)-anchor_offset1,...
    %                                anchor(:,1)-anchor_offset1) ;
    sidx_offset = (anchor-anchor_offset1)*[isz1 1]'+sidx_offset_const ;
	%- Inner loop
	RDC1 = blank_RDC1 ;
	for k = 1:N_dots
        sidx = stamp_idx + sidx_offset(k) ;
        RDC1(sidx) = max(RDC1(sidx),stamp_cache(:,I(k)+s2i_add)) ;
	end
    %- Store and continue with the next frame
    RDC(isz1:-1:1,:,t) = RDC1 ;
end

%--- Return RDC
%%%%% End of file RENDER_RDC.M
