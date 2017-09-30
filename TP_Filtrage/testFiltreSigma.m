img=imread('TP1.3.jpg');

colormap(gray(256));

H = [];

gaussian = addNoiseGaus(img, 20);

gaussian2 = addNoiseGaus(img, 50);

ps = addNoisePS(img, 0.05);

H = [rmse(imageToGrayScale(img), gaussian), rmse(imageToGrayScale(img), gaussian2), rmse(imageToGrayScale(img), ps)];

S = [128,32,64,128,128];
M = [5,9,9,9,15];

for k = 1:size(S,2)
    averageImage = filtrageSigmaVect(gaussian, S(k), M(k));
    
    H(1+k*2,1) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,1) = H(1,1) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageSigmaVect(gaussian2, S(k), M(k));
    
    H(1+k*2,2) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,2) = H(1,2) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageSigmaVect(ps, S(k), M(k));
    
    H(1+k*2,3) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,3) = H(1,3) - rmse(imageToGrayScale(img), averageImage);
end

disp(H);

filteredImage = filtrageSigmaVect(gaussian, 128, 9);

subplot(1,2,1);
image(gaussian);
axis image;
title('Noisy Image');
subplot(1,2,2);
image(filteredImage);
axis image;
title('Treated Image');