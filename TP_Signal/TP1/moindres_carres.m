N = 128;
u = rand(N,1);
E = 0.01*randn(N,1);
a1 = 1;
a2 = 1.5;
a3 = -0.7;
Theta = [a1;a2;a3];

U = [u,u.^2,u.^3];
Y = U*Theta + E;

ThetaEst = inv(U.'*U)*U.'*Y;

disp(ThetaEst);