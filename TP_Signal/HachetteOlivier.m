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
% Nous avons bien les trois pics (et sym�triques) caract�rstiques des 
% fr�quences pr�sentes
% dans le signal, par contre nous perdons l'information temporelle puisque
% les trois ne sont pas pr�sentes en m�me temps dans le signal.

% 3.
% Nous pouvons utiliser un spectrogramme pour avoir une information
% temporelle sur le signal. Cela revient � faire des transform�e de fourier
% localement.

% 4.
figure;
spectrogram(s,32,16);
% on voit bien que les fr�quences sont r�parties temporellement mais la
% bande de fr�quence est plut�t grande : 0.1 de large en normalis�e donc ce
% n'est pas tr�s pr�cis pour les fr�quence.
% A l'inverse on voit tr�s clairement le moment ou cela change de fr�quence
% temporellement.

% 5.
figure;
spectrogram(s,256,128);
% Nous avons l'inverse, le changement est confondu sur une plus grande zone
% temporelle mais l'information sur la fr�quence du signal est beaucoup 
% plus pr�cise.

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
% La fr�quence d'�chantiollonage est inf�rieur � 2 fois la fr�quence du
% signal 300. On perds donc cette information de fr�quence et on a donc
% seulement deux pics aux fr�quences 200 et 100. De plus l'energie apport�e
% par la sinusoide de fr�quence 300 s'est r�partie sur les deux autres.

%% Estimation de la fr�quence Doppler
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
% nous avons bien deux pics sym�triques correspondants � la transform�e de
% fourier d'un cosinus (et � la fr�quence 2MHz)

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
% nous avons bien deux pics sym�triques mais bien que la fr�quences ne soit
% plus la m�me vu que fd <<< f0 nous avons l'impression que ces derniers se
% trouvent au m�me endroit, c'est � dire 2Mhz

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
% il y a deux pics � + et - 5kHz soit la fr�quence fd, elle a bien �t�
% isol�e, par contre cela a aussi
% d�cal� la fr�quence du signal principal f0 comme nous le voyons
% maintenant � 4MHz au lieu de 2MHz

% 3.a.i.
% Nous pouvons filter le signal avec un filtre passe bas de fc � 1MHz par
% exemple, ce qui nous permet d'isoler le signal de fr�quence 5kHz, il
% suffit alors de calculer la densit� spectrale de puissance et le max nous
% donne la fr�quence fd

% d = fdesign.lowpass('Fp,Fst,Ap,Ast',1*10^6,2*10^6,0.5,40,fe);
% Hd = design(d,'equiripple');
% output = filter(Hd,sd);
% Pxx = pwelch(output, hamming(32), 16);
% plot((1:129)*fe, 10*log10(Pxx));

% on remarque aussi que dans la fft c'est un max, d'o�
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
% Nous avons l'apparition de deux pics caract�ristiques d'un signal
% sinusoidal, ces pics se trouvent � la fr�quence suivante :
[value, index] = max(fftshift(abs(S)));
disp(abs(f(index))); %5.4973 * 10^3