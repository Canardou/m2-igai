function plotpoints(I,J,NbPoints)
%plotpoints Plot points over an image adding the plot to the current window.  
%    plotpoints(I,J) Plot the points defined by their row indices in vector
%    I and by their column indices in vector J.
%
%    plotpoints(I,J,NbPoints) Plot only the NbPoints first points.
%
% See also: hold.
% 

% $Author: A. Crouzil $    $Date: 2014/02/07 09:01:32 $    $Revision: 1.0 $


if nargin < 3, NbPoints=length(I); end;
hold on;
for p=1:NbPoints
 set(text(J(p)+2,I(p)-3,int2str(p)),'Color','blue','FontSize',10);
 plot(J(p),I(p),'y+');
end
hold off;
