[I1] = imread('lena.jpg');
I1=double(I1);
I1=round((I1(:,:,1)+I1(:,:,2)+I1(:,:,3))/3);

Angle=pi/4;
lCentre=floor(size(I1,1)/2);
cCentre=floor(size(I1,2)/2);
I2=rotim(I1,Angle,lCentre,cCentre);

figure; subplot(1,2,1);
image(I1); colormap(gray(256)); axis image;
subplot(1,2,2);
image(I2); colormap(gray(256)); axis image;

