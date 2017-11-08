set(groot,'DefaultFigureColormap',gray);
%% 1.
im=double(imread('Phantom.png'));
K = fft2(im);
%imagesc(log(abs(fftshift(K))));
%axis image;
%% 2.
K12 = K;
K12(:,1:2:size(K12,2)) = 0;
%imagesc(log(abs(fftshift(K12))));
%axis image;
imagesc(ifft2(K12));
axis image;
% REPLIEMENT !
%% 3.
K13 = K;
K13(rand(size(K13))>0.5) = 0;
figure;
imagesc(abs(ifft2(K13)));
axis image;
%% 4.
im = imresize(double(rgb2gray(imread('Phantom.png'))),[64 64]);
mask_2D = rand(size(im));
omega = find(mask_2D(1:size(mask_2D,2)/2,:)<0.5);
A = @(Z) A_fhp(Z,omega);
At = @(Z) At_fhp(Z,omega,size(im,1));
y = A(im(:));
y = y + randn(size(y));
irm_initial = At(y);
Res = tveq_logbarrier(irm_initial,A,At,y,1e-1,2,1e-8,600);
figure;
subplot(1,3,1)
imagesc(reshape(irm_initial,size(im)));
axis image;
subplot(1,3,2)
imagesc(reshape(Res,size(im)));
axis image;
subplot(1,3,3)
imagesc(im);
axis image;