%% 1.
amp = 0.3;
fe = 44100;
duration = 4;
f0 = 440;
t = 1/fe:1/fe:duration;
s = amp*sin(2*pi*f0*t);
sound(s, fe);
figure;
plot(t,s);
xlabel('Temps (secondes)')
ylabel('Signal')

S = fft(s);
% frequence
dF = fe/size(t,2);
f = -fe/2:dF:fe/2-dF;
figure;
plot(f, fftshift(abs(S)));
xlabel('Frequence (hertz)')
ylabel('Module')
% figure;
% plot(f/fe, fftshift(abs(S)));
% xlabel('Frequence (normalisee)')
% ylabel('Module')

%% 2.
s = generate_sound(440,4,0.3,0.2,1,fe);
for k = 2:10
    s = s + generate_sound(440*k,4,0.3,0.2,1,fe);
end
sound(s,fe);
figure;
plot(t,s);
xlabel('Temps (secondes)')
ylabel('Signal')

%%
s = generate_sound(440,4,0.3,0.2,1,fe);
for k = 2:10
    tmp = generate_sound(440*k,4,0.3,0.4*rand(1),2*rand(1),fe);
    s = s + [tmp zeros(1,size(s,2)-size(tmp,2))];
end
sound(s,fe);
figure;
plot(t,s);
xlabel('Temps (secondes)')
ylabel('Signal')

%%
s = generate_sound(440,4,0.3,0.2,1,fe);
for k = 2:10
    s = s + generate_sound(440*k*rand(1),4,0.3,0.2,1,fe);
end
sound(s,fe);
figure;
plot(t,s);
xlabel('Temps (secondes)')
ylabel('Signal')

%% 3.

mat = spectrogram(s,fe,1024,128,1024);

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

%duration must be more than attack and release
function s = generate_sound(f0,duration,amp,attack,release,fe)
    if attack + release > duration
        error('attack + release must be inferior or equal to the duration')
    end
    t_attack = 1/fe:1/fe:attack;
    t_sustain = 1/fe:1/fe:duration-attack-release;
    t_release = 1/fe:1/fe:release;
    s_attack = (t_attack/attack).*amp.*sin(2*pi*f0*t_attack);
    s_sustain = amp*sin(2*pi*f0*t_sustain);
    s_release = ((release-t_release)/release).*amp.*sin(2*pi*f0*t_release);
    s = [s_attack s_sustain s_release];
end