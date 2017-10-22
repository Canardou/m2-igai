fe = 100;
f0 = 20;
f0norm = f0 / fe; % Normaliser
N = 50;
[h, n, h0] = rif(N, f0norm);

subplot(1, 3, 1);
hold on
plot(n, h);
plot(n, h0, 'r+');
hold off
subplot(1, 3, 2);
plot(linspace(-1/2, 1/2, 1024), abs(fftshift(fft(h,1024))));
subplot(1, 3, 3);

% LA PHASE C'EST 'ANGLE'
plot(linspace(-1/2, 1/2, 1024), unwrap(angle(fftshift(fft(h,1024)))));

function [h, n, h0] = rif(N, f0)

	% Fonction porte de rep. impulsionnelle:
	n = (1:N/2);
	h = sin(2*pi*(n)*f0) ./ (pi*n);
	h0 = [h(end-1:-1:1) 2*f0 h];

	% Windows
       	h = h0 .* hamming(N)';
	%h = h0 .* hanning(N)';

	% Coefficients
	n = [-1*n(end-1:-1:1) 0 n];

end

