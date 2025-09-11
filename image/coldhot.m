function map = coldhot(N_colors)

%COLDHOT -- Default Leabra color map  [lblue dblue grey red yellow]
%
% map = coldhot
% map = coldhot(N_colors)
%
% MAP is a N_colors-by-3 matrix of RGB values containing a
% colormap composed of 5 ranges:
%  a) light blue range for the most negative portion
%  b) dark blue range for the moderately negative portion
%  c) grey range for the near-zero portion
%  d) red range for the moderately positive portion
%  e) yellow range for the most positive portion
%
% N_COLORS specifies the number of colors in the palette. When not
% supplied, it defaults to the length of the current colormap.
% Odd numbers are recommended because then the midpoint is well defined.
%
% Example (show a matrix W of positive and negative weights):
%   imagesc(W,[-1 +1]) ; colormap(coldhot(101)) ; colorbar ;
%
% See also JET, GRAY, HOT, COOL, COLORMAP, RGBPLOT, GRAPH3D.

% Original coding Randall O'Reilly and Chadley Dawson, 1995
% Source: pdp++/src/ta_misc/colorscale.cc    
% Ported to Matlab by Alexander Petrov, http://alexpetrov.com
% $Revision: 1.0 $  $Date: 2006/04/07 16:48 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

if (nargin<1)  N_colors = size(get(gcf,'colormap'),1) ; end

RGB_anchors = [ 0  1  1 ; ...   % lblue
                0  0  1 ; ...   % dblue
               .5 .5 .5 ; ...   % grey (facing down)
               .5 .5 .5 ; ...   % grey (facing up)
                1  0  0 ; ...   % red
                1  1  0 ] ;     % yellow

anchor_pos = [0 .25 .50 .50 .75 1].*(N_colors-1) + 1 ; 
anchor_pos([2 3]) = floor(anchor_pos([2 3])) ;    % facing down
anchor_pos([4 5]) = ceil(anchor_pos([4 5])) ;    % facing up
%@@@ BUG: Even N_COLORS result in two identical grey entries in the middle.

map = zeros(N_colors,3) ;
for k = 2:size(RGB_anchors,1)
    lo = anchor_pos(k-1) ;
    hi = anchor_pos(k) ;
    if (lo<hi)
        ladder = [0:1/(hi-lo):1]' ;
        RGB_lo = RGB_anchors(k-1,:) ;
        RGB_hi = RGB_anchors(k,:) ;
        map(lo:hi,:) = (1-ladder)*RGB_lo + ladder*RGB_hi ;
    %else degenerate case at the midpoint -- do nothing
    end
end

%--- MAP
%%%%% End of file COLDHOT.M
