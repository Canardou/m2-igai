% Enonce
h = [1 4 7; 2 5 8; 3 6 9];
x = round(5*rand(7,7));
hpad=padarray(h,(size(x)-size(h))./2);
% a.
a = conv2(double(h),double(x));
% figure(1);
% image(a), colorbar;
% colormap(gray(256));
% axis image;
% b.

H = fft2(double(h),9,9);
X = fft2(double(x),9,9);
P = double(H.*X);
colormap(gray(256));
% figure(2);
% subplot(1,3,1);
% image(abs(fftshift(X))), colorbar;
% axis image;
% title('X');
% subplot(1,3,2);
% image(abs(fftshift(H))), colorbar;
% axis image;
% title('H');
% subplot(1,3,3);
% image(abs(ifft2(P))), colorbar;
% axis image;
% title('P');
% c.
p2 = imfilter(x, h, 'conv', 'circular', 'same');
% figure(3);
% colormap(gray(256));
% image(p2), colorbar;
% axis image;
% d.
center=(size(x)+1)/2;
hpad1=circshift(hpad, 1-center);

S=fft2(hpad1);
ConvCircFreq=ifft2(S.*fft2(x));

% figure(4);
% colormap(gray(256));
% image(real(ConvCircFreq)), colorbar;
% axis image;

%3.e
szx=size(x);
ConvCircBCCB=zeros(size(x));
BCCB=[];
% pour chaque pixel de l'image on calcul le circshift qui permet d'avoir la
% bonne combinaison linéaire de xi (image vectorisé)
% cela nous permet de former la BCCB (et l'image pour verifier que notre
% calcul est juste)
for i=1:szx(1)
    for j=1:szx(2)
        dcenter=(size(x)+1)/2-[i,j];
        hpad2=circshift(rot90(hpad,2), -dcenter);
        ConvCircBCCB(i,j)=hpad2(:)'*x(:);
        BCCB=[BCCB hpad2(:)];
    end
end

figure(1)
subplot(1,5,1)
imagesc(a)
title('3.a.');
axis image;
subplot(1,5,2)
imagesc(abs(ifft2(P)))
title('3.b.');
axis image;
subplot(1,5,3)
imagesc(p2)
title('3.c.');
axis image;
subplot(1,5,4)
imagesc(abs(ConvCircFreq))
title('3.d.');
axis image;
subplot(1,5,5)
imagesc(ConvCircBCCB)
title('3.e.');
axis image;
figure(2)
imagesc(BCCB)
title('BCCB');
axis image;
