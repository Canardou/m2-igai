%%
% 4, 5.a
i_ideal=double(imread('coat_of_arms.png'));
h = 1/double(20*20)*double(ones(20,20));
%h = double(fspecial('gaussian',20,5));
i = conv2(i_ideal,h,'same');
figure(1);
subplot(1,3,1);
image(i_ideal);
title('Ideal');
axis image;
subplot(1,3,2);
image(i);
title('Floutee');
axis image;
subplot(1,3,3);
image(mat2gray(h)*256);
title('Matrice du flou');
axis image;
colormap(gray(256));
% 4.b
figure(2);
subplot(1,3,1);
m = log10(abs(fftshift(fft2(i_ideal))));
imagesc(m);
title('FT i ideal');
axis image;
subplot(1,3,2);
imagesc(log10(abs(fftshift(fft2(i)))));
title('FT i');
axis image;
% on voit apparaitre le motif du filtre dans la fft
subplot(1,3,3);
imagesc(abs(fftshift(fft2(h))));
% les valeurs de fft de H sont surtout concentrés au centre
% les autres valeurs sont très proches de 0
title('FT h');
axis image;
colormap(gray);
% 4.c
H = fft2(h,size(i,1),size(i,2));
i_fft_naif = fft2(i)./H;
i_retrouvee_naive = ifft2(i_fft_naif);
% H contient des valeurs proches de 0
% on se retrouve donc à effectuer des divisions par 0 (sur les bords HF)
% lorsqu'on repasse en en spatiale l'image contient des valeurs NaN
figure(3);
subplot(1,4,1);
imagesc(real(i_retrouvee_naive));
title('Methode naive');
axis image;
% 4.d
I = fft2(i);
S = 1/255;
for x=1:size(i,1)
    for y=1:size(i,2)
        if H(x,y) > S
            i_fft_seuil(x,y) = I(x,y)/H(x,y);
        else
            i_fft_seuil(x,y) = I(x,y);
        end
    end
end
i_retrouvee = ifft2(i_fft_seuil);
subplot(1,4,2);
imagesc(real(i_retrouvee));
% la fft ne contient plus de valeurs trop grandes
% la transformée inverse fonctionne donc même si le resultat laisse
% apparaitre des distorsions
title('Methode seuil');
axis image;
% 4.e
i_wiener = deconvwnr(i,h,10^-5);
subplot(1,4,3);
imagesc(real(i_wiener));
title('Filtre de wiener');
axis image;
subplot(1,4,4);
imagesc(i);
title('Sans traitement');
axis image;
colormap(gray);
%%
% 6.
i_ideal=double(imread('coat_of_arms.png'));
h = 1/double(20*20)*double(ones(20,20));
%h = double(fspecial('gaussian',20,5));
i = conv2(i_ideal,h,'same');

Px = calculPuissance(i);
RSBdB = 40;
Pn = Px / 10^(RSBdB/10);
% Pn = Sigma²
Sigma = sqrt(Pn);

i = rajouterBruitGaussien(i, Sigma);

figure(1);
subplot(1,3,1);
image(i_ideal);
title('Ideal');
axis image;
subplot(1,3,2);
image(i);
title('Floutee et bruitee');
axis image;
subplot(1,3,3);
image(mat2gray(h)*256);
title('Matrice du flou');
axis image;
colormap(gray(256));
% 6.b
figure(2);
subplot(1,3,1);
m = log10(abs(fftshift(fft2(i_ideal))));
imagesc(m);
title('FT i ideal');
axis image;
subplot(1,3,2);
imagesc(log10(abs(fftshift(fft2(i)))));
title('FT i');
% On peut remarquer la fft est uniformément bruitée
% et que l'effet de h est moins visible de fait
axis image;
subplot(1,3,3);
imagesc(abs(fftshift(fft2(h))));
title('FT h');
axis image;
colormap(gray);
% 6.c
H = fft2(h,size(i,1),size(i,2));
i_fft_naif = fft2(i)./H;
i_retrouvee_naive = ifft2(i_fft_naif);
figure(3);
subplot(1,4,1);
imagesc(real(i_retrouvee_naive));
title('Methode naive');
axis image;
% 6.d
I = fft2(i);
S = 1/255;
for x=1:size(i,1)
    for y=1:size(i,2)
        if H(x,y) > S
            i_fft_seuil(x,y) = I(x,y)/H(x,y);
        else
            i_fft_seuil(x,y) = I(x,y);
        end
    end
end
i_retrouvee = ifft2(i_fft_seuil);
subplot(1,4,2);
% la méthode seuilé donne un plutôt bon résultat mais augmente le bruit
imagesc(real(i_retrouvee));
title('Methode seuil');
axis image;
% 6.e
i_wiener = deconvwnr(i,h,10^-3);
subplot(1,4,3);
imagesc(real(i_wiener));
title('Filtre de wiener');
% le filtre de wiener s'adapte au bruit et donne donc un bien meilleur
% résultat
axis image;
subplot(1,4,4);
imagesc(i);
title('Sans traitement');
axis image;
colormap(gray);