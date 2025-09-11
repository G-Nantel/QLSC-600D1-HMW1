function  AAparams = render_RDC_aux(Rparams)

%RENDER_RDC_AUX --  Auxiliary params for rendering random-dot cinematograms
%   
%  AAparams = render_RDC_aux(Rparams)
%
%  This is an auxiliary function called by RDC_PARAMS.
%  It sets up various grids used by RENDER_RDC and RENDER_RDC_DELUXE.
%
%  See also RDC_PARAMS, RENDER_RDC, RENDER_RDC_DELUXE.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.1 $  $Date: 2006/06/07 15:40 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

deluxep = Rparams.deluxep ;
img_size = Rparams.img_size ;
dot_radius = Rparams.dot_diam/2 * Rparams.pix_deg ;      % in pixels
aa = Rparams.anti_alias ;   % minipixels per pixel, always an odd number

%%-- For anti-aliasing purposes, each pixel is divided into "minipixels"
coarse_offset = ceil(dot_radius)+1 ;
coarse_grid = [-coarse_offset+1 : coarse_offset-1] ;
coarse_N = length(coarse_grid) ;        % always an odd number

fine_offset = ((aa*coarse_N)-1)/2 ;
fine_grid = [-fine_offset : fine_offset] ./ aa ;
fine_N = length(fine_grid) ;              % == aa * coarse_N
[X,Y] = meshgrid(fine_grid',fine_grid) ;  % Note: xy->ji inversion!!

%%-- A "dot stamp" is a disc rendered in black and white over the
% fine grid and then compressed to grey levels on the coarse grid.
% Calculate and cache away one stamp centered on each minipixel
% of the "local grid." The local grid tiles a single coarse pixel.
stamp_size = [coarse_N coarse_N] ;
cache_size = [aa+2 aa+2] ;
delta_offset = (aa+3)/2 ;
local_grid = [-delta_offset+1 : delta_offset-1]./aa ;
stamp_cache = zeros([prod(stamp_size) prod(cache_size)]) ;
Rmax2 = dot_radius^2 ;
q = 255/(aa^2) ;
for ix = 1:cache_size(2)
    x0 = local_grid(ix) ;
    for iy = 1:cache_size(1)
        %- render a solid disk over the fine grid
        y0 = local_grid(iy) ;
        R2 = (X-x0).^2 + (Y-y0).^2 ;
        canvas = zeros([fine_N fine_N]) ;
        canvas(find(R2<=Rmax2)) = q ;
        %- average onto the coarse grid
        stamp = squeeze(sum(reshape(canvas,[aa coarse_N, fine_N]))) ;
        stamp = squeeze(sum(reshape(stamp',[aa coarse_N, coarse_N])))' ;
        %- cache for use in RENDER_RDC1. Note: xy->ji inversion!!
        stamp_cache(:,sub2ind(cache_size,iy,ix)) = stamp(:) ;
    end
end

%%-- Facilitate the identification of the relevant stamps
% Usage: sub2ind(cache_size,I(:,2),I(:,1)) == I*s2i_mult+s2i_add(1)
% The four entries in s2i_add denote 4 neighboring nodes in 2x2 config
csz1 = cache_size(1) ;
s2i_mult = [csz1 1]' ;  % NB: 'ji' order, not the canonical 'ij'
if (deluxep)
    s2i_add = [-csz1 0 1-csz1 1] ; % flipud([SW NW SE NE])
else
    s2i_add = -csz1 ;              % SW only
end

%%-- Make a linear index for quick stamping into a 2D canvas
canvas = zeros(img_size) ;
canvas(1:stamp_size(1),1:stamp_size(2)) = 1 ;
stamp_idx = find(canvas==1) - 1 ;

%%-- Pack and return
AAparams.deluxep = deluxep ;
AAparams.img_size = img_size ;
AAparams.dot_radius = dot_radius ;
AAparams.aa = aa ;
AAparams.stamp_size = stamp_size ;
AAparams.anchor_offset = coarse_offset ;
AAparams.delta_offset = delta_offset ;
if (deluxep)
    AAparams.stamp_cache = stamp_cache ;         % double
else
    AAparams.stamp_cache = uint8(stamp_cache) ;  % uint8
end
AAparams.cache_size = cache_size ;
AAparams.s2i_mult = s2i_mult ;
AAparams.s2i_add = s2i_add ;
AAparams.stamp_idx = stamp_idx ;

%%-- Plot the stamps for debugging purposes
% for ix = 1:cache_size(2)
%     for iy = 1:cache_size(1)
% 		subplotrc(cache_size(1),cache_size(2),iy,ix) ;
%         stamp=reshape(stamp_cache(:,sub2ind(cache_size,iy,ix)),stamp_size);
% 		imagesc(coarse_grid,coarse_grid,stamp,[0 255]) ;
% 		set(gca,'xtick',[],'ytick',[]); axis square ; axis xy ;
% 		%title(sprintf('i=%d, j=%d',iy,ix)) ;
%     end
% end

%--- Return AAPARAMS
%%%%% End of file RENDER_RDC_AUX.M
