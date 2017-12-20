%% 1.
[y,Fs] = audioread('clap.wav');
[rms, indices] = rms_level(y,128,64);

figure(1);
plot(indices/Fs,rms);

figure(2);
rms_db = 10*log(rms);
plot(indices/Fs,rms_db);

%% 2.
% Entre 0.2 et 1.2s la décroissance semble linéaire
start_linear = 0.2*Fs;
end_linear = 1.2*Fs-1;

y_linear = y(start_linear:end_linear);

[rms, indices] = rms_level(y_linear,128,64);
rms_db = 10*log(rms);

figure(3);
plot(indices/Fs,rms_db);

p = polyfit(indices/Fs,rms_db,1);

TR60 = -60/p(1);
%la reverberation a lieu pendant TR60 secondes

%% 3.

[y2,Fs] = audioread('singing.wav');
y3 = conv(y,y2);
%%
sound(y,Fs);
%%
sound(y2,Fs);
%%
soundsc(y3,Fs);

function [rms, indices] = rms_level(x,windowLength, windowsHop)
    %step = floor(size(x,1)/(windowLength-windowsHop));
    indices = 1:windowsHop:size(x,1)-(windowLength);
    rms = zeros(1,size(indices,2));
    for k = 1:size(indices,2)
        rms_part = sqrt(sum(x(indices(k):indices(k)+windowLength).^2)/windowLength);
        rms(1,k) = rms_part;
    end
end