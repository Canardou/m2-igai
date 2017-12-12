function [Smooth,DerivI,DerivJ,DerivII,DerivJJ,DerivIJ]=gaussmask2(Sigma)
%gaussmask2 2D convolution masks corresponding to Gaussian filter and its
% partial derivatives.
%    [Smooth,DerivI,DerivJ,DerivII,DerivJJ,DerivIJ] = gaussmask2(Sigma)
%    returns masks corresponding to : smoothing (Smooth), first vertical
%    derivative (DerivI), first horizontal derivative (DerivJ), second vertical
%    derivative (DerivII), second horizontal derivative (DerivJJ), second
%    cross derivative (DerivIJ)
%
% See also: conv2.
% 

% $Author: A. Crouzil $    $Date: 2016/12/04 17:01:32 $    $Revision: 1.0 $

WindowSize=2*ceil(3*Sigma)+1;
n=floor(WindowSize/2);
[J,I]=meshgrid(-n:n);
Expo=exp(-(I.^2+J.^2)./(2.*Sigma.^2));
Smooth=Expo./sum(sum(Expo));
if nargout>=2
  DerivI=-I.*Expo;
  DerivI=DerivI./sum(sum(DerivI(1:n,:)));
end
if nargout>=3
  DerivJ=DerivI';
end
if nargout>=4
  DerivII=(I.^2/(Sigma.^2)-1).*Expo/(2*pi*Sigma.^4);
end
if nargout>=5
  DerivJJ=DerivII';
end
if nargout>=6
  DerivIJ=-DerivI.*J/Sigma.^2;
end




