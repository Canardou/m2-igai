% 4, 5.a
i_ideal=double(imread('coat_of_arms.png'));
%h = 1/double(20*20)*double(ones(20,20));
h = double(fspecial('gaussian',20,5));
i = conv2(i_ideal,h,'same');
figure(1);
subplot(3,1,1);
image(i_ideal);
axis image;
subplot(3,1,2);
image(i);
axis image;
subplot(3,1,3);
image(mat2gray(h)*256);
axis image;
colormap(gray(256));
% 4.b
figure(2);
subplot(3,1,1);
m = log10(abs(fftshift(fft2(i_ideal))));
imagesc(m);
axis image;
subplot(3,1,2);
imagesc(log10(abs(fftshift(fft2(i)))));
axis image;
subplot(3,1,3);
imagesc(abs(fftshift(fft2(h))));
axis image;
colormap(gray);
% 4.c
H = fft2(h,size(i,2),size(i,2));
H_inv = inv(H);
i_fft_naif = fft2(i,size(i,2),size(i,2))./H_inv;
i_retrouvee = ifft2(i_fft_naif);
figure(3);
image(real(i_retrouvee));
axis image;
colormap(gray(256));
% 4.d
I = fftshift(fft2(i));
S = 255;
for x=1:size(i,1)
    for y=1:size(i,2)
        if i_fft_naif(x,y) > S
            i_fft_naif(x,y) = I(x,y);
        end
    end
end
i_retrouvee = ifft2(i_fft_naif);
figure(4);
image(real(i_retrouvee));
axis image;
colormap(gray(256));