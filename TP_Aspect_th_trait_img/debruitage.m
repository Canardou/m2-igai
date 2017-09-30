imgInt=imread('lena512.jpg');

colormap(gray(256));

img = double(imgInt);
% Débruitage
% 1.
% Calcul de la puissance de l'image
Px = calculPuissance(img);
% RSBdB = 20 d'où
Pn = Px / 10^2;
% Pn = Sigma²
Sigma = sqrt(Pn);

ib = rajouterBruitGaussien(img, Sigma);

figure(1);
image(ib);
colormap(gray(256));
colorbar;
title(['Image bruitee - Sigma ' num2str(Sigma)]);
axis image;
% Verification
n = Sigma*randn(size(img));
Pn = calculPuissance(n);
Px = calculPuissance(ib);
% RSB = 20
RSBdB = 10*log10(Px/Pn) 
errQ = erreurQuadratiqueMoyenne(ib,img)

% 2.
% a.
errP = PSNR(255,ib,img)

errQ = [];
for k = 0.5:0.01:1.5
    h = fspecial('gaussian',5,k);
    imt = conv2(ib, h, 'same');
    errQ = [errQ, erreurQuadratiqueMoyenne(imt,img)];
end
x = 0.5:0.01:1.5;
figure(2);
plot(x,errQ);
indexmin = find(min(errQ) == errQ); 
xmin = x(indexmin); 
ymin = errQ(indexmin);
strmin = ['Sigma = ',num2str(xmin)];
text(xmin,ymin,strmin,'HorizontalAlignment','left');

h = fspecial('gaussian',5,xmin);
imt = conv2(ib, h, 'same');
figure(3);
image(imt);
colormap(gray(256));
colorbar;
title(['Image traitee']);
axis image;
% b.
w = 9;
sigma_d = 3;
sigma_r = 20;

[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

dim = size(ib);
B = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
      
         % Extract local region.
         iMin = max(i-w,1);
         iMax = min(i+w,dim(1));
         jMin = max(j-w,1);
         jMax = min(j+w,dim(2));
         I = ib(iMin:iMax,jMin:jMax);
      
         % Compute Gaussian intensity weights.
         H = exp(-(I-ib(i,j)).^2/(2*sigma_r^2));
      
         % Calculate bilateral filter response.
         F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
         B(i,j) = sum(F(:).*I(:))/sum(F(:));
               
   end
end
figure(4);
image(B)
colormap(gray(256));
colorbar;
title(['Image traitee bilateral']);
axis image;