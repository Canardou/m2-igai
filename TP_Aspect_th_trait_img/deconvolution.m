% Enonce
h = [1 4 7; 2 5 8; 3 6 9];
x = round(5*rand(7,7));
% a.
a = conv2(double(h),double(x));
figure(1);
image(a), colorbar;
colormap(gray(256));
axis image;
% b.
figure(2);
H = fft2(double(h),9,9);
X = fft2(double(x),9,9);
P = double(H.*X);
colormap(gray(256));
subplot(1,3,1);
image(abs(fftshift(X))), colorbar;
axis image;
title('X');
subplot(1,3,2);
image(abs(fftshift(H))), colorbar;
axis image;
title('H');
subplot(1,3,3);
image(abs(ifft2(P))), colorbar;
axis image;
title('P');
% c.
p2 = imfilter(x, h, 'conv', 'circular', 'same');
figure(3);
colormap(gray(256));
image(p2), colorbar;
axis image;
% d.
figure(4);
colormap(gray(256));
d = ifft2(fft2(x).*fft2(h,7,7));
image(abs(d)), colorbar;
axis image;
% e.
hpadded = circshift(padarray(h(:), 20, 0),25);
hcirc = gallery('circul',hpadded);
% b = cell(3,1);
% b{1,1} = circulant(h(:,1));
% b{2,1} = circulant(h(:,2));
% b{3,1} = circulant(h(:,3));
% H = cell2mat(circulant(b)); 
% Hpadded = padarray(H,[20 20],0,'both');
% Hcirc = circshift(Hpadded,-24);
p3 = reshape(double(hcirc)*x(:),[7 7]);

figure(5);
subplot(2,1,1);
colormap(gray(256));
image(p2);
axis image;
subplot(2,1,2);
image(p3);
axis image;

function r=circulant(h)
    r = [h(2) h(1) h(3);h(3) h(2) h(1);h(1) h(3) h(2)];
end

