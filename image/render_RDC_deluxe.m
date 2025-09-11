function  RDC = render_RDC_deluxe(Rparams,RDC_spec)

%RENDER_RDC_DELUXE -- High-precision rendering of random-dot cinematograms
%   
%  RDC = render_RDC_deluxe(Rparams,RDC_spec)
%
%  Rparams is a structure produced by RDC_PARAMS with deluxep=true.
%  RDC_spec is a specification produced by MAKE_RDC_SPEC.
%
%  The resulting RDC is a 3D uint8 matrix of grayscale images or "frames".
%  It is fully compatible with RDCs rendered by RENDER_RDC. The only
%  difference is that the anti-aliasing of the individual dots is more
%  accurate.  Specifically, RENDER_RDC_DELUXE averages four "stamps" to
%  render a dot, whereas the plain RENDER_RDC uses a single "stamp".
%
%  To merge RDCs, use:  RDC = max(RDC1,RDC2)
%
%  Example:
%    Rparams=RDC_params([],true) ;  % the second arg *must* be true
%    RDC_spec = make_RDC_spec(Rparams,10,30) ;   % 30 dots moving 1 o'clock
%    RDC = render_RDC_deluxe(Rparams,RDC_spec) ;
%    M = RDC_movie(Rparams,RDC) ; movie(M,3) ;
%
%  See also RENDER_RDC, RDC_PARAMS, MAKE_RDC_SPEC, RDC_MOVIE, IMAGESC.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.1 $  $Date: 2006/06/07 15:00 $
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

blank_RDC1 = zeros(img_size) ;
%RDC = repmat(uint8(blank_RDC1),[1 1 N_frames]) ;
for t = N_frames:-1:1     % go backwards to bypass memalloc for RDC
    %- Convert degrees -> pixels
    %ji = RDC_spec(:,1:2,t).*pix_deg + ji_origin ; % degrees --> pixels
    ji = RDC_spec(:,1:2,t).*pix_deg ;  % +ji_origin into sidx_offset_const
	%- Represent each coordinate as anchor+delta
	anchor = round(ji) ;      % [N_dots x 2]
	d = (ji-anchor).*aa ;     % -.5*aa <= d <= .5*aa
	%-- Identify the indices of the 4 cached stamps that must be averaged
	% to interpolate a circular disk centered on D on the "local grid".
	dmin = floor(d) ;
	I = (dmin+delta_offset) * s2i_mult ;    % in lieu of sub2ind(...)
	%- Interpolation weights: each stamp is a convex linear combination
	% of four cached stamps whose position bracket the desired position
	wgt1 = d-dmin ;  % interpolation weight of the high stamp in a pair
	wgt0 = 1-wgt1 ;  % interpolation weight of the low stamp in a pair
	W = [wgt0(:,2).*wgt0(:,1),...    % SW
         wgt0(:,2).*wgt1(:,1),...    % NW
         wgt1(:,2).*wgt0(:,1),...    % SE
         wgt1(:,2).*wgt1(:,1)]' ;    % NE
	%- Indices of the "stamp footstep" on the canvas
	% Note that ANCHOR, like JI, has column 1=j=x and column 2=i=y
	% sidx_offset = sub2ind(img_size,anchor(:,2)-anchor_offset1,...
    %                                anchor(:,1)-anchor_offset1) ;
    sidx_offset = (anchor-anchor_offset1)*[isz1 1]'+sidx_offset_const ;
	%- Inner loop
	RDC1 = blank_RDC1 ;
	for k = 1:N_dots
        sidx = stamp_idx + sidx_offset(k) ;
        RDC1(sidx) = RDC1(sidx) + stamp_cache(:,I(k)+s2i_add)*W(:,k) ;
        %RDC1(sidx) = max(RDC1(sidx),stamp_cache(:,I(k)+s2i_add)*W(:,k)) ;
	end
    %- Store and continue with the next frame
    RDC(isz1:-1:1,:,t) = uint8(min(255,RDC1)) ;
    %RDC(isz1:-1:1,:,t) = uint8(RDC1) ;
end

%--- Return RDC
%%%%% End of file RENDER_RDC_DELUXE.M
