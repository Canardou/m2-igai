% 1.
Fs=500; % sample rate 
tf=2; % 2 seconds
t=0:1/Fs:tf-1/Fs
f1=0;
f2=150; % start @ 0 Hz, go up to 150Hz
semi_t=0:1/Fs:(tf/2-1/Fs);
sl=2*((f2-f1)/2);
f1=f1*semi_t+(sl.*semi_t/2);
f2=f2+(f2*semi_t-sl.*semi_t)/2;
f=[f1 f2];
y=cos(2*pi*f.*t);
plot(t,y);
% 2.
spectrogram(y,128,120,128,1e3)