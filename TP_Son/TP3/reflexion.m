fe = 44100;
duration = 1;
t = 1/44100:1/44100:1;

%% Qst 1
dirac = zeros(size(t));
dirac(1) = 1;

spectre = spectrogram(dirac, fe, 256,128,1024);
[rms, indices] = rms_level(dirac,128,64);

figure(2);
plot(t/fe,dirac);

figure(3);
plot(indices/fe,rms);

%% Qst 2

y = echo(dirac, fe, 0.8, 0.2);

[s,Fs] = audioread('singing_16k.wav');
s = s';
singing_echo = echo(s, Fs, 0.8, 0.2);
soundsc(singing_echo, Fs);


%% Qst 3

delay = 0.2;
ammortissement = 0.8;
h = filter([1 zeros(size(2:delay*fe)) ammortissement],[1],dirac);

%% Qst 4-5

h = filter([1],[1 zeros(size(2:delay*fe)) ammortissement],dirac);
singing_echo = filter([1],[1 zeros(size(2:delay*Fs)) ammortissement],s);
singing_echo_func = delay_func(s, Fs, 0.5, 0.2);
soundsc(singing_echo, Fs);

%% Qst 6

singing_echo_low_pass = delay_low_pass(s, Fs, 0.5, 0.2, 10);
soundsc(singing_echo_low_pass, Fs);
%%
singing_echo_low_pass = delay_low_pass(s, Fs, 0.8, 0.2, 10);
soundsc(singing_echo_low_pass, Fs);

function y = delay_low_pass(x, fe, amortissement, delay, K)
    sample_delay = delay*fe;
    y = x;
    for delays = sample_delay:sample_delay:size(y,2)
        moy = [zeros(size(y(1:end)))];
        for k = 0:K-1
            moy = moy + [zeros(1,delays+k) y(1:end-delays-k)];
        end
        y = y + amortissement/K * moy;
        amortissement = amortissement * amortissement;
    end
end

function y = echo(x, fe, amortissement, delay)
    sample_delay = delay*fe;
    y = x + amortissement * [zeros(1,sample_delay) x(1:end-sample_delay)];
end

function y = delay_func(x, fe, amortissement, delay)
    sample_delay = delay*fe;
    y = x;
    for delays = sample_delay:sample_delay:size(y,2)
        y = y + amortissement * [zeros(1,delays) y(1:end-delays)];
        amortissement = amortissement * amortissement;
    end
end

function mat = spectrogram(signal, fe, window, overlap, Nfft)
    %step = floor(size(signal,2)/(window-2*overlap));
    echantillons = 1:overlap:size(signal,2)-(window);
    mat = zeros(size(echantillons,2),Nfft/2);
    for k = 1:size(echantillons,2)
        fft_tot = abs(fft(signal(1,echantillons(k):echantillons(k)+window),Nfft));
        mat(k,:) = 20*log10(fft_tot(1:Nfft/2));
    end
    dF = fe/Nfft;
    f = 0:dF:fe/2-dF;
    t = 0:1/fe:size(signal,2)/fe;
    imagesc(t,f,transpose(mat));
    set(gca,'YDir','normal')
end

function [rms, indices] = rms_level(x,windowLength, windowsHop)
    %step = floor(size(x,1)/(windowLength-windowsHop));
    indices = 1:windowsHop:size(x,2)-(windowLength);
    rms = zeros(1,size(indices,2));
    for k = 1:size(indices,2)
        rms_part = sqrt(sum(x(indices(k):indices(k)+windowLength).^2)/windowLength);
        rms(1,k) = rms_part;
    end
end