img=imread('TP1.3.jpg');

colormap(gray(256));

imgGray = imageToGrayScale(img);

subplot(1,2,1);
image(imgGray);
axis image;
title('Gray Image');
subplot(1,2,2);
image(img);
axis image;
title('Color Image');

figure

colormap(gray(256));

noisy = addNoisePS(img, 0.02);

daspect([1 1 1])

image(noisy);
axis image;
title('Noisy Image - k=0.02');
rmse(imageToGrayScale(img), noisy)

figure

colormap(gray(256));

noisy = addNoisePS(img, 0.50);

image(noisy);
axis image;
title('Noisy Image - k=0.05');
rmse(imageToGrayScale(img), noisy)

figure

colormap(gray(256));

noisy = addNoisePS(img, 0.10);

image(noisy);
axis image;
title('Noisy Image - k=0.10');
rmse(imageToGrayScale(img), noisy)

figure

colormap(gray(256));

gaussian = addNoiseGaus(img, 10);

image(gaussian);
axis image;
title('Noisy Image - Sigma = 10');

figure

colormap(gray(256));

gaussian = addNoiseGaus(img, 20);

image(gaussian);
axis image;
title('Noisy Image - Sigma = 20');

figure

colormap(gray(256));

gaussian = addNoiseGaus(img, 50);

image(gaussian);
axis image;
title('Noisy Image - Sigma = 50');