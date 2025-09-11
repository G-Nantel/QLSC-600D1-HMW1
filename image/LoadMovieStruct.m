function  LoadMovieStruct(images,movieStruct)

%LOADMOVIESTRUCT -- Load images into movieStruct's off-screen buffers.
%  
%  LoadMovieStruct(imges,movieStruct)
%
%  MOVIESTRUCT must be created by MakeMovieStruct. IMAGES must be
%  either a cell array or a 3-D array of grayscale images. The size
%  of each image must match the corresponding imageSize with which
%  the movieStruct was created. The total number N must also match.
%
%  The same movieStruct can be used repeatedly to play different movies
%  by simply loading different IMAGES and calling PlayMovieStruct after
%  each load. The original creator MakeMovieStruct never loads any images.
%
%  See also PLAYMOVIESTRUCT, MAKEMOVIESTRUCT, MOVIESTRUCTDEMO, SCREEN.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/12/10 16:10 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

%-- Unpack the movieStruct fields
winPtr = movieStruct.windowPtr ;
bufferPtr = movieStruct.bufferPtr ;
imageRect = movieStruct.imageRect ;

if (iscell(images))       % a set of images, possibly of different sizes
   nImages = length(images) ;
elseif (isnumeric(images))
   nImages = size(images,3) ;
else
   error('IMAGES must be either a cell array or a 3-D (or 2-D) matrix.') ;
end
if (nImages > length(bufferPtr))
   error('Too many images for this movieStruct.') ;
elseif (nImages < length(bufferPtr))
   error('Too few images for this movieStruct.') ;
end

%-- Do the main work
if (iscell(images))
   for k = 1:nImages
      sz = size(images{k}) ;
      if (any(sz ~= imageRect(k,[RectBottom RectRight])))
         warning(sprintf('Image %d does not fit into its imageRect.',k)) ;
      end
      SCREEN(bufferPtr(k),'PutImage',images{k},imageRect(k,:)) ;
   end
else  % (isnumeric(images))
   sz = size(images) ;
   if (any(imageRect(:,RectBottom)~=sz(1)) | ...
       any(imageRect(:,RectRight )~=sz(2)) )
      warning('These images do not fit into these imageRectangles.') ;
   end
   for k = 1:nImages      
      SCREEN(bufferPtr(k),'PutImage',images(:,:,k),imageRect(k,:)) ;
   end
end

%--- Return no value
%%%%% End of file LOADMOVIESTRUCT.M
