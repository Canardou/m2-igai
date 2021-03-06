img=imread('TP1.3.jpg');

colormap(gray(256));

H = [];

gaussian = addNoiseGaus(img, 20);

gaussian2 = addNoiseGaus(img, 50);

ps = addNoisePS(img, 0.05);

H = [rmse(imageToGrayScale(img), gaussian), rmse(imageToGrayScale(img), gaussian2), rmse(imageToGrayScale(img), ps)];

M = [3,5,7,9];

for k = 1:size(M,2)
    averageImage = filtrageSNN(gaussian, M(k));
    
    H(1+k*2,1) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,1) = H(1,1) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageSNN(gaussian2, M(k));
    
    H(1+k*2,2) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,2) = H(1,2) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageSNN(ps, M(k));
    
    H(1+k*2,3) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,3) = H(1,3) - rmse(imageToGrayScale(img), averageImage);
end

disp(H);

colormap(gray(256));

filteredImage = filtrageSNN(ps, 3);

subplot(1,2,1);
image(ps);
axis image;
title('Noisy Image');
subplot(1,2,2);
image(filteredImage);
axis image;
title('Treated Image');