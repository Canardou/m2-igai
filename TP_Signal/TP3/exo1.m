
% h(n) = 2*f0*sinc(2*pi*n*f0);

% normalisation des frequences
f0 = 20*10^3;
fe = 100*10^3;
fn = f0/fe; % frequence normalisee
N = 0:0.01:1;
Order = 128;
coefs = rif(Order,fn/2);
figure(1);
plot(coefs)
figure(2);
g = abs(fftshift(fft(coefs,1024)));
s = size(g(1024/2:end),2);
plot((0:s-1)/s,g(1024/2:end)/0.08);
hold on
%-- design the bandpass filter --
rect = 1*(N>=0 & N<fn);
rect2= rect+0*(N>=fn);
%-- plotting the ideal filter --%
plot(N,rect2,'linewidth',2);
title('bandpass ideal filter');
xlabel('frequency'); ylabel('Magnitude')
% axis([0 1 0 1.5])
hold off;
figure(3)
plot(angle(fft(coefs)));

function c = rif(N,f0)
    n = 1:N/2;
    c = (0.54 - 0.46*cos(2*pi*n/N)) .* sin(2*pi*n*f0) ./ (pi*n);
    c = [c(end:-1:1), 2*f0*0.08, c];
end