imgInt=imread('lena512.jpg');

BAR = waitbar(0,'Filtre gaussien...');

img = double(imgInt);
% Débruitage
% 1.
% Calcul de la puissance de l'image
Px = calculPuissance(img);
% RSBdB = 20
RSBdB = 20;
Pn = Px / 10^(RSBdB/10);
% Pn = Sigma²
Sigma = sqrt(Pn);

ib = rajouterBruitGaussien(img, Sigma);

% Verification
n = Sigma*randn(size(img));
Pn = calculPuissance(n);
Px = calculPuissance(ib);
% RSB = 20
RSBdB = 10*log10(Px/Pn)
errQ = erreurQuadratiqueMoyenne(ib,img)

% 2.
% a.
errP = PSNR(255,ib,img);

errQ = [];
for k = 0.5:0.01:1.5
    h = fspecial('gaussian',5,k);
    imt = conv2(ib, h, 'same');
    errQ = [errQ, erreurQuadratiqueMoyenne(imt,img)];
    waitbar(0.5*(k-0.5),BAR,'Filtre gaussien...');
end

x = 0.5:0.01:1.5;
figure(1);
plot(x,errQ);
xlabel('Sigma filtre');
ylabel('Erreur quadratique moyenne');
indexmin = find(min(errQ) == errQ); 
xmin = x(indexmin); 
ymin = errQ(indexmin);
strmin = ['\leftarrow Minimum : Sigma = ',num2str(xmin)];
text(xmin,ymin,strmin,'HorizontalAlignment','left');

h = fspecial('gaussian',5,xmin);
imt = conv2(ib, h, 'same');

PSNRTraiteeGaussien = PSNR(255,imt,img)
MSETraiteeGaussien = errQ(indexmin)

figure(2);
subplot(2,3,1);
image(img);
axis image;
colormap(gray(256));
colorbar;
title('Image');
subplot(2,3,2);
image(ib);
colormap(gray(256));
title(['Image bruitee - Sigma ' num2str(Sigma)]);
axis image;
subplot(2,3,3);
image(imt);
colormap(gray(256));
title(['Image traitee - Sigma ' num2str(xmin)]);
axis image;
subplot(2,3,4);
histogram(img);
subplot(2,3,5);
histogram(ib);
subplot(2,3,6);
histogram(imt);
% b.
ib2 = ib(150:350,150:350);
img2 = img(150:350,150:350);

errQ = [];
waitbar(0.5,BAR,'Filtre bilateral...');
progress = 0.5;
D = [0.7,0.85,0.9,0.95,1.1]; 
R = [45,48,50,52,55];
for d = 1:size(D,2)
    for r = 1:size(R,2)
        w = 9;
        sigma_d = D(d);
        sigma_r = R(r);

        % Distance decrease factor (gaussian filter)
        [X,Y] = meshgrid(-w:w,-w:w);
        G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

        dim = size(ib2);
        B = zeros(dim);
        for i = 1:dim(1)
           for j = 1:dim(2)

                 % Extract local region.
                 iMin = max(i-w,1);
                 iMax = min(i+w,dim(1));
                 jMin = max(j-w,1);
                 jMax = min(j+w,dim(2));
                 I = ib2(iMin:iMax,jMin:jMax);

                 % Compute Gaussian intensity weights.
                 H = exp(-(I-ib2(i,j)).^2/(2*sigma_r^2));

                 % Calculate bilateral filter response.
                 F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
                 B(i,j) = sum(F(:).*I(:))/sum(F(:));

           end
        end
        progress = progress + 1/(size(D,2)*size(R,2)*2);
        waitbar(progress,BAR,'Filtre bilateral...');
        errQ(r,d) = erreurQuadratiqueMoyenne(B,img2);
    end
end
close(BAR);
figure(4);
surf(D,R,errQ);
hold on
[~, i] = min(errQ(:));
[r, c] = ind2sub(size(errQ), i);
h = scatter3(D(c),R(r),errQ(i),'filled');
h.SizeData = 150;
hold off

% use best
w = 9;
sigma_d = D(c);
sigma_r = R(r);

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

PSNRTraiteeBilateral = PSNR(255,B,img)
MSETraiteeGaussien = erreurQuadratiqueMoyenne(B,img)

figure(5);
subplot(2,3,1);
image(img);
axis image;
colormap(gray(256));
colorbar;
title('Image');
subplot(2,3,2);
image(ib);
colormap(gray(256));
title(['Image bruitee - Sigma ' num2str(Sigma)]);
axis image;
subplot(2,3,3);
image(B);
colormap(gray(256));
title(['Image traitee - Sd ' num2str(D(c)) ', Sr ' num2str(R(r))]);
axis image;
subplot(2,3,4);
histogram(img);
subplot(2,3,5);
histogram(ib);
subplot(2,3,6);
histogram(B);