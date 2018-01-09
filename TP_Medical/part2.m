load('bmod.mat');
subplot(2,2,1);
imagesc(bmod);
colormap(gray);

delta_n = [0 1 0; 0 -1 0; 0 0 0];
delta_s = [0 0 0; 0 -1 0; 0 1 0];
delta_e = [0 0 0; 0 -1 1; 0 0 0];
delta_w = [0 0 0; 1 -1 0; 0 0 0];

I = bmod;
lambda = 0.10;

c = @(x) exp(-(x/200).^2);

for k=1:20
    In = conv2(I,delta_n,'same');
    Is = conv2(I,delta_s,'same');
    Ie = conv2(I,delta_e,'same');
    Iw = conv2(I,delta_w,'same');
    I = I + lambda*(c(In).*In + c(Is).*Is + c(Ie).*Ie + c(Iw).*Iw);
end
subplot(2,2,2);
imagesc(I);
colormap(gray);

sigma = abs(( bmod - I ) / abs(5));
ENL = ( ( bmod - I ) ./ sigma );
Cx = ( ENL.*sigma.^2 - sigma.^2 ) / ( ENL + 1 );
w = Cx / ( Cx + I.^2 / ENL );
Is = I + w * ( bmod - I );

subplot(2,2,3);
imagesc(Is);
colormap(gray);