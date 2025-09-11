function h = imagesc1(varargin)

%IMAGESC1 -- Scale data and display as a gray image with colorbar.
%
%  IMAGESC1(...) is the same as IMAGESC(...) except the data is scaled
%  to use the full colormap, the colormap is set to 'gray', the axis
%  is set to 'image', and a colorbar is requested.
% 
%  See also IMAGESC, IMAGE, IMSHOW, TRUESIZE, PCOLOR.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/11/28 21:40 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

hh = imagesc(varargin{:}) ;
axis('image') ;
colormap('gray') ; %colorbar ;
% truesize ;   % Depends on the IMAGES toolbox

if nargout > 0
    h = hh;
end

%%%%% End of IMAGESC1.M
