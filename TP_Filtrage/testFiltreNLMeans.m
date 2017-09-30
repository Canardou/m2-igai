img=imread('TP1.1.jpg');

colormap(gray(256));

gaussian = addNoiseGaus(img, 20);

filteredImage = filtrageNLMeans(gaussian, 3);

subplot(1,2,1);
image(gaussian);
title('Noisy Image');
subplot(1,2,2);
image(filteredImage);
title('Treated Image');

initial_error = rmse(imageToGrayScale(img), gaussian)
error = rmse(imageToGrayScale(img), filteredImage)
delta_error = error-initial_error

figure

colormap(gray(256));

gaussian = addNoiseGaus(img, 50);

filteredImage = filtrageNLMeans(gaussian, 3);

subplot(1,2,1);
image(gaussian);
title('Noisy Image');
subplot(1,2,2);
image(filteredImage);
title('Treated Image');

initial_error = rmse(imageToGrayScale(img), gaussian)
error = rmse(imageToGrayScale(img), filteredImage)
delta_error = error-initial_error