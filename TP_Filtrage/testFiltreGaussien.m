img=imread('TP1.3.jpg');

colormap(gray(256));

H = [];

gaussian = addNoiseGaus(img, 20);

gaussian2 = addNoiseGaus(img, 50);

ps = addNoisePS(img, 0.05);

H = [rmse(imageToGrayScale(img), gaussian), rmse(imageToGrayScale(img), gaussian2), rmse(imageToGrayScale(img), ps)];

disp(H);

%Filter is apply only to with a small matrix (which contains the most
%important terms, we could go higher it wouldn't change anything but a
%smaller matrix 3x3 gives worst results
K = [5,5,5,5,5,5];
K2 = [0.7,0.85,1,2,20,50];

for k = 1:size(K,2)
    averageImage = filtrageGaussien(gaussian, K(k), K2(k));
    
    H(1+k*2,1) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,1) = H(1,1) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageGaussien(gaussian2, K(k), K2(k));
    
    H(1+k*2,2) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,2) = H(1,2) - rmse(imageToGrayScale(img), averageImage);
    
    averageImage = filtrageGaussien(ps, K(k), K2(k));
    
    H(1+k*2,3) = rmse(imageToGrayScale(img), averageImage);
    H(1+k*2+1,3) = H(1,3) - rmse(imageToGrayScale(img), averageImage);
end

disp(H);

colormap(gray(256));

gaussian = addNoiseGaus(img, 20);

filteredImage = filtrageGaussienOctave(gaussian, 5, 0.85);

subplot(1,2,1);
image(gaussian);
axis image;
title('Noisy Image');
subplot(1,2,2);
image(filteredImage);
axis image;
title('Treated Image');