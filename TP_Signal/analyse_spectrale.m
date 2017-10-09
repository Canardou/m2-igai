% 1.
N = 512;
f1 = 0.15;
f2 = 0.18;
fe = 1;
t = (1:N)/fe;
signal = exp(-2i*pi*f1*t) + exp(-2i*pi*f2*t);
% SNRdB = 10 = 20 * log10( Ps / Pb )
sigma = sqrt(2/(10^2));
y=signal+sigma*randn(size(t));
plot(real(y));
% 2.
figure;
Nfft = 1024;
ydft = fft(y,Nfft);
psdx = (1 / Nfft) * fftshift( abs(ydft).^2 );
psdx(2:end-1) = 2*psdx(2:end-1);
freq = (1:Nfft)/Nfft - 0.5;

plot(freq,20*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Normalized Frequency 1/fe')
ylabel('Power (dB)')
% 3.
figure;
subplot(3,1,1);
M = 24;
plot(pwelch(y,M,M/2));
subplot(3,1,2);
M = 100;
plot(pwelch(y,M,M/2));
subplot(3,1,3);
M = 250;
plot(pwelch(y,M,M/2));
% 4.
figure;
p = 2;
m = arburg(y,10);
plot(abs(m));
