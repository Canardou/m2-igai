fe = 2000;
f0 = 200;
duration = 0.05;
N = fe*duration;
t = (1:N)/fe;
y = sin(2*pi*f0*t);
plot(y);
figure;
f = fft(y);
plot(f);
figure;
duration = 0.5;
N = fe*duration;
t = (1:N)/fe;
y = sin(2*pi*f0*t);
plot(y);
figure;
f = fft(y);
plot(f);