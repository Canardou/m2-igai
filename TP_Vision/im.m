function [h] = im(M)
%im Display a gray level image.  
%    im(M) Display the image defined by the gray level matrix M. Each gray
%    level must be in [0,255].
%
%    h = im(M) returns the image handle.
%
% See also: image.
% 

% $Author: A. Crouzil $    $Date: 2014/02/07 09:01:32 $    $Revision: 1.0 $

if nargin~=1, error('Wrong number of input parameters'); end
if nargout>1, error('Wrong number of output parameters'); end

figure(gcf);
colormap(gray(256));
hh=image(M);
axis image;
%axis off;
drawnow;
if nargout==1, h=hh; end

