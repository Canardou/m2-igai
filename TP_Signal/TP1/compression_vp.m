P = phantom(256);
figure;
colormap(gray);
imagesc(P);
axis image;
[U,S,V] = svd(P);
D = diag(S);
figure;
plot(D);
ULess = U(1:end,1:50);
SLess = S(1:50,1:50);
VLess = V(1:end,1:50);
% les plus grandes valeurs singulière
PRecomp = ULess * SLess * VLess';
figure;
colormap(gray);
imagesc(PRecomp);
axis image;