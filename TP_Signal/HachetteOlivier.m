%% Moindres carres
% 1.
t = 1:19/1900:20;
signal = 1 + log10(t);
Ps = mean(signal.*signal);
% SNRdB = 8 = 20 * log10( Ps / Pb )
% 8 = 20 log10(Ps/pb)
% 10^(8/20) = Ps/Pb
% Pb = Ps/(10^(8/20))
% Pour le bruit gaussien Pb = sigma^2
sigma = sqrt(Ps/(10^(8/20)));
Y=signal+sigma*randn(size(t));
plot(Y);

% 2.
% A = 2x1
% E = 1901x1
% donc U = 1901x2
a1 = 1;
a2 = 1;
E = sigma*randn(size(t))';
A = [a1 a2]';
U = [ones(size(t));log10(t)]';
Y = U*A + E;
figure;
plot(Y);

% 3.
AEst = inv(U.'*U)*U.'*Y;
disp(AEst);

% 4.
figure;
hold on;
plot(Y);
plot(U*AEst, 'LineWidth',2);
plot(signal, 'LineWidth',1);
legend('Signal bruite', 'Signal estime', 'Signal original');
%% Spectre et spectrogramme de signaux deterministes
% 1.
fe = 1000;
t = 1/fe:1/fe:3;
t3 = 1/fe:1/fe:1;
s = [sin(2*pi*100*t3) sin(2*pi*200*t3) sin(2*pi*300*t3)];
figure;
plot(t,s);
xlabel('Temps (secondes)')
ylabel('Signal')

% 2.
S = fft(s);
% frequence
dF = fe/size(t,2);
f = -fe/2:dF:fe/2-dF;
figure;
plot(f, fftshift(abs(S)));
xlabel('Frequence (hertz)')
ylabel('Module')
figure;
plot(f/fe, fftshift(abs(S)));
xlabel('Frequence (normalisee)')
ylabel('Module')
% Nous avons bien les trois pics (et symétriques) caractérstiques des 
% fréquences présentes
% dans le signal, par contre nous perdons l'information temporelle puisque
% les trois ne sont pas présentes en même temps dans le signal.

% 3.
% Nous pouvons utiliser un spectrogramme pour avoir une information
% temporelle sur le signal. Cela revient à faire des transformée de fourier
% localement.

% 4.
figure;
spectrogram(s,32,16);
% on voit bien que les fréquences sont réparties temporellement mais la
% bande de fréquence est plutôt grande : 0.1 de large en normalisée donc ce
% n'est pas très précis pour les fréquence.
% A l'inverse on voit très clairement le moment ou cela change de fréquence
% temporellement.

% 5.
figure;
spectrogram(s,256,128);
% Nous avons l'inverse, le changement est confondu sur une plus grande zone
% temporelle mais l'information sur la fréquence du signal est beaucoup 
% plus précise.

% 6.
fe = 500;
t = 1/fe:1/fe:3;
t3 = 1/fe:1/fe:1;
s = [sin(2*pi*100*t3) sin(2*pi*200*t3) sin(2*pi*300*t3)];
S = fft(s);
% frequence
dF = fe/size(t,2);
f = -fe/2:dF:fe/2-dF;
figure;
plot(f, fftshift(abs(S)));
xlabel('Frequence (hertz)')
ylabel('Module')
% La fréquence d'échantiollonage est inférieur à 2 fois la fréquence du
% signal 300. On perds donc cette information de fréquence et on a donc
% seulement deux pics aux fréquences 200 et 100. De plus l'energie apportée
% par la sinusoide de fréquence 300 s'est répartie sur les deux autres.

%% Estimation de la fréquence Doppler
% 1. 
fe = 10*10^6; % 10MHz
f0 = 2*10^6;
t = 0:1/fe:10^-3;
e = cos(2 * pi * f0 * t);
plot(t,e);
xlabel('Temps (secondes)')
ylabel('e(t)')
E = fft(e);
% frequence
dF = fe/size(t,2);
f = -fe/2:dF:fe/2-dF;
figure;
plot(f, fftshift(abs(E)));
xlabel('Frequence (hertz)')
ylabel('Module')
% nous avons bien deux pics symétriques correspondants à la transformée de
% fourier d'un cosinus (et à la fréquence 2MHz)

% 2.
figure;
fd = 5 * 10^3;
s = cos(2 * pi * (f0 + fd) * t);
plot(t,s);
xlabel('Temps (secondes)')
ylabel('s(t)')
S = fft(s);
% frequence
dF = fe/size(t,2);
f = -fe/2:dF:fe/2-dF;
figure;
plot(f, fftshift(abs(S)));
xlabel('Frequence (hertz)')
ylabel('Module')
% nous avons bien deux pics symétriques mais bien que la fréquences ne soit
% plus la même vu que fd <<< f0 nous avons l'impression que ces derniers se
% trouvent au même endroit, c'est à dire 2Mhz

% 3.a.
sd = s.*e;
SD = fft(sd);
% frequence
dF = fe/size(t,2);
f = -fe/2:dF:fe/2-dF;
figure;
plot(f, fftshift(abs(SD)));
xlabel('Frequence (hertz)')
ylabel('Module')
% il y a deux pics à + et - 5kHz soit la fréquence fd, elle a bien été
% isolée, par contre cela a aussi
% décalé la fréquence du signal principal f0 comme nous le voyons
% maintenant à 4MHz au lieu de 2MHz

% 3.a.i.
% Nous pouvons filter le signal avec un filtre passe bas de fc à 1MHz par
% exemple, ce qui nous permet d'isoler le signal de fréquence 5kHz, il
% suffit alors de calculer la densité spectrale de puissance et le max nous
% donne la fréquence fd

% d = fdesign.lowpass('Fp,Fst,Ap,Ast',1*10^6,2*10^6,0.5,40,fe);
% Hd = design(d,'equiripple');
% output = filter(Hd,sd);
% Pxx = pwelch(output, hamming(32), 16);
% plot((1:129)*fe, 10*log10(Pxx));

% on remarque aussi que dans la fft c'est un max, d'où
[value, index] = max(fftshift(abs(SD)));
disp(abs(f(index))); %5.4995 * 10^3

% 3.b
fe = f0;
t = 0:1/fe:10^-3;
s = cos(2 * pi * (f0 + fd) * t);
plot(t,s);
xlabel('Temps (secondes)')
ylabel('e(t)')
S = fft(s);
% frequence
dF = fe/size(t,2);
f = -fe/2:dF:fe/2-dF;
figure;
plot(f, fftshift(abs(S)));
xlabel('Frequence (hertz)')
ylabel('Module')
% Nous avons l'apparition de deux pics caractéristiques d'un signal
% sinusoidal, ces pics se trouvent à la fréquence suivante :
[value, index] = max(fftshift(abs(S)));
disp(abs(f(index))); %5.4973 * 10^3