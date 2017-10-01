img=imread('TP1.1.jpg');

gaussian = double(addNoiseGaus(img, 20));

std(gaussian(:))

filteredImage = filtrageNLMeans(gaussian, 5, std(gaussian(:)));

figure;
colormap(gray(256));
subplot(2,2,1);
image(gaussian);
title(['Noisy Image - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), gaussian))]);
axis image;
subplot(2,2,2);
image(filteredImage);
title(['NL-means filter - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), filteredImage))]);
axis image;
subplot(2,2,3);
moyImage = filtrageMoy(imageToGrayScale(img),5);
image(moyImage);
title(['Average filter - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), moyImage))]);
axis image;
subplot(2,2,4);
gausImage=filtrageGaussien(imageToGrayScale(img),5,0.85)
image(gausImage);
title(['Gaussian filter - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), gausImage))]);
axis image;

img=imread('TP1.4.jpg');

gaussian = double(addNoiseGaus(img, 20));

std(gaussian(:))

filteredImage = filtrageNLMeans(gaussian, 5, std(gaussian(:)));

figure;
colormap(gray(256));
subplot(2,2,1);
image(gaussian);
title(['Noisy Image - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), gaussian))]);
axis image;
subplot(2,2,2);
image(filteredImage);
title(['NL-means filter - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), filteredImage))]);
axis image;
subplot(2,2,3);
moyImage = filtrageMoy(imageToGrayScale(img),5);
image(moyImage);
title(['Average filter - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), moyImage))]);
axis image;
subplot(2,2,4);
gausImage=filtrageGaussien(imageToGrayScale(img),5,0.85)
image(gausImage);
title(['Gaussian filter - RMSE : ' num2str(rmse(double(imageToGrayScale(img)), gausImage))]);
axis image;

