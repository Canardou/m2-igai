%% I 0 A
load('us.mat');
load('demod.mat');
%% B
colormap(gray);
imagesc(im);

%% C
t = (1:size(im(:,1),1))/(60*10^6)*1540/2*1000;
plot(t,im(:,1));
% signal reçu par le capteur après un aller retour pour chaque delta
% d'acquisition

%% 1 A
x = im;
y = demod;
figure;
plot(x(:,1))
hold on
plot(y(:,1))
% B enveloppe du signal

%% 2 A B
figure;
colormap(gray);
imagesc(y);
figure;
histogram(y);
% image en valeur absolue plus lisible
% on voit qu'il n'y a plus de valeurs négatives

%% C D
y_log = log(y);
colormap(gray);
imagesc(y_log);
figure;
histogram(y_log);
% les valeurs sont lissés donc moins d'importance pour la distance au
% capteur

%% E
bmod = log(10+1*y);
colormap(gray);
imagesc(bmod);
figure;
histogram(bmod);

%% 3
t = (1:size(im(:,1),1))/size(im(:,1),1)-0.5;
X = fft(x(:,1));
plot(t,abs(fftshift(X)));

%% 4
Y = fft(y(:,1));
plot(t,abs(fftshift(Y)));
% supprime les hautes fréquences

%% 5 A
plot(imag(demod_cplx(:,1)))
hold on
plot(x(:,1))

%% B
% décaler et abs
% X(t) = a(t) cos(2 pi fo t)
% TH(X(t)) = a(t)*sin(2 pi fo t)
TH_appr = im(1:end-3)+1i*im(4:end);
figure;
imagesc(abs(TH_appr));
