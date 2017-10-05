% Enonce
h = [1 4 7; 2 5 8; 3 6 9];
x = round(5*rand(7,7));
% a.
a = conv2(h,x);
colormap(gray);
image(a), colorbar;
% b.
figure;
H = fft2(double(h));
X = fft2(double(x));
P = fft2(double(conv2(h,x)));
colormap(gray);
subplot(1,3,1);
axis image;
image(abs(fftshift(X))), colorbar;
title('X');
subplot(1,3,2);
axis image;
image(abs(fftshift(H))), colorbar;
title('H');
subplot(1,3,3);
axis image;
image(abs(fftshift(P))), colorbar;
title('P');
% c.
p2 = imfilter(x, h);
figure;
colormap(gray);
image(p2), colorbar;
