% Exercice vraiment documenté.
% Fréquences
fc = 2000;
fe = 10000;
fcNorm = fc / fe;

% deltaF
deltaF = 500;
deltaFNorm = deltaF / fe;

% Calcul du filtre (Hanning, avec 2 'n')
N = floor(3.1 / deltaFNorm);
filtreHanning = rif2(fcNorm, N) .* hanning(N)';

% Calcul du filtre (Rectangulaire)
N = floor(0.9 / deltaFNorm);
filtreRect = rif2(fcNorm, N);

% Calcul du filtre (Blackman)
N = floor(5.5 / deltaFNorm);
filtreBlackman = rif2(fcNorm, N) .* blackman(N)';

% Calcul du filtre (Hamming)
N = floor(3.3 / deltaFNorm);
filtre = rif2(fcNorm, N) .* hamming(N)';
n = (1:N/2);   % ^ Meh ?
n = [-n(end:-1:1) 0 n];

% Filtre idéal et fenêtré
figure('Name', 'Filtre');
subplot(3,1,1);
plot(n, filtre);
title('filtre hamming')
subplot(3,1,2);
plot(n, hamming_maison(N));
title('coefs hamming')
subplot(3,1,3);
plot(n, h0(n, fcNorm));
title('filtre h0')

% Signal cool
%n = linspace(0, 1, fe);
%x = sin(2*pi*(2*fc)*n);
% Attention, les ^ fréqs. normalisées n'ont rien à faire là.

% Convolution (e.g filtrage)
%y = imfilter(x, filtre);

% Vérification sur un signal réel (sinusoïdal)
%figure('Name', 'Signal original');
%subplot(2,1,1);
%plot(n,x);
%subplot(2,1,2);
%plot(linspace(-0.5, 0.5, size(x,2)), abs(fftshift(fft(x))));

%figure('Name', 'Signal filtré');	
%subplot(2,1,1);
%plot(n,y);	
%subplot(2,1,2);
%plot(linspace(-0.5, 0.5, size(y,2)), abs(fftshift(fft(y))));

% Comparaison des fenêtres
figure('Name', 'Filtres (domaine fréquentiel)');
hold on;
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtre,1024))));
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtreHanning,1024))));
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtreRect,1024))));
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtreBlackman,1024))));
legend('Hamming', 'Hanning', 'Rect', 'Blackman');
% Filtre passe-bande
%N = 200;
%N = 80;
N = N; % En faisant varier le N on fait varier la vitesse de coupure (?)
filtreBas = rif2(fcNorm, N); % Ici N = 66, je ne sais pas si c'est correct (Anakin le sait, lui.)
filtreBande = rif3(fcNorm, 3000/fe, 50, N);
filtreBande2 = rif3(fcNorm, 3000/fe, 50, 25);
filtreBande3 = rif3(fcNorm, 3000/fe, 50, 200);
figure('Name', 'Transformation en passe-bande');
hold on;
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtreBas, 1024))));
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtreBande, 1024))));
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtreBande2, 1024))));
plot(linspace(-0.5, 0.5, 1024), abs(fftshift(fft(filtreBande3, 1024))));
legend('Passe bas', ['N = ' N], 'N = 25', 'N = 200');

% Filtre idéal de caractérisitiques:
function [filtre] = rif2(f0Norm, N)

	n = (1:floor(N+0.5)/2);
	filtre = h0(n, f0Norm);
	if (mod(N, 2) == 0)
		filtre = [ filtre(end:-1:2) 2*f0Norm filtre ];
	else
		filtre = [ filtre(end:-1:1) 2*f0Norm filtre ];
	end

	% Attention au '-'
	%n = [-n(end:-1:1) 0 n];

end

% Filtre passe-bande
function [filtre] = rif3(f0Norm, fCentreBandeNorm, B, N)

	% Génère le filtre idéal porte avec une largeur de bande de B%
	filtrePasseBas = rif2(f0Norm*(B/100), N);
	filtre = 2 * filtrePasseBas .* cos(2*pi*(1:size(filtrePasseBas, 2))*fCentreBandeNorm);
	%figure('Name', 'Test');
	%hold on;
	%plot(filtrePasseBas);
	%plot(filtre);

end

% Rép. impuls. du filtre idéal
function [nf] = h0(n, fcNorm)

	% Expression standard
	nf = sin(2*pi*fcNorm*n) ./ (pi*n);

end

% Fenêtre de Hamming
function [w] = hamming_maison(N)

	% Attention, l'intervalle d'une Hamming est [0, N-1]
	w = 0.54 - (0.46*cos(2*pi*(1:N)/N));

end

