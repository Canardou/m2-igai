% Données
fe = 1000;
f0 = 50;
f1 = 200;
fc = 100; % Arbitrairement
f0norm = f0/fe;
f1norm = f1/fe;
fcNorm = fc/fe;

% Bande de transition
df = 50;
dfNorm = df / fe;

% Signal en entrée
t = linspace(0, 1, fe);
y = sin(2*pi*f0*t) + sin(2*pi*f1*t);

% Filtre (Hamming et 53dB d'atténuation)
filtre53 = h0(fcNorm, 3.3) .* hamming(floor(3.3/dfNorm));

% Filtre (Blackman et 74dB d'atténuation)
filtre74 = h0(fcNorm, 5.5) .* blackman(floor(5.5/dfNorm));

% Résultats
figure('Name', 'Comparaison de filtres')

subplot(3,1,1);
plot(t, y);
title('Signal original');

subplot(3,1,2);
plot(t, imfilter(y, filtre53));
title('Signal filtré et atténué à 53dB');

subplot(3,1,3);
Y = fft(y);
% Reconstruit la fft en masquant une partie du module, la phase reste intacte
momo = abs(Y);
momo(fc:end-fc) = 0;
plot(t, ifft(momo.*exp(j*angle(Y))));
title('Signal filtré dans le domaine de Fourier');

function [ideal] = h0(fcNorm, N)

	n = (1:N/2);
	ideal = sin(2*pi*fcNorm*n) ./ (pi*n);

	if (mod(N, 2) == 0)
		ideal = [ ideal(end:-1:2) 2*fcNorm ideal ];
	else
		ideal = [ ideal(end:-1:1) 2*fcNorm ideal ];
	end

end

