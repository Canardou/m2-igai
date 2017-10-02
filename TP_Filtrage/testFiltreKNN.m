img=imread('TP1.3.jpg');

colormap(gray(256));

H = [];

gaussian = addNoiseGaus(img, 20);

gaussian2 = addNoiseGaus(img, 50);

ps = addNoisePS(img, 0.05);

H = [rmse(imageToGrayScale(img), gaussian), rmse(imageToGrayScale(img), gaussian2), rmse(imageToGrayScale(img), ps)];

K = [4,5,6,7,5];
M = [3,3,3,3,5];

for k = 1:size(K,2)
    averageImage = filtrageKNN(gaussian, K(k), M(k));
    
    H(1+k*2,1) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,1) = H(1,1) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageKNN(gaussian2, K(k), M(k));
    
    H(1+k*2,2) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,2) = H(1,2) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageKNN(ps, K(k), M(k));
    
    H(1+k*2,3) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,3) = H(1,3) - rmse(imageToGrayScale(img), averageImage);
end

disp(H);

filteredImage = filtrageKNN(ps, 4, 3);

subplot(1,2,1);
image(ps(55:80,220:260));
axis image;
title('Noisy Image');
subplot(1,2,2);
image(filteredImage(55:80,220:260));
axis image;
title('Treated Image');