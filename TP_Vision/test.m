CONESG=double(imread('conesgauche.pgm'));
CONESD=double(imread('conesdroite.pgm'));

figure;

RES=nonmax(CONESG,20);
[I,J]=select1(RES,50);
im(CONESG);
plotpoints(I,J);

figure;

[I,J]=select2(RES,25);
im(CONESG);
plotpoints(I,J);

%%
CONESG=double(imread('conesdroite.pgm'));
RES = response(CONESG,1,2,'Shi-Tomasi');

CONESD=double(imread('conesgauche.pgm'));
RES2 = response(CONESD,1,2,'Shi-Tomasi');

RES = nonmax(RES,20);
RES2 = nonmax(RES2,20);
figure;
subplot(2,3,1);
[I,J]=select2(RES,20);
im(CONESG);
title('Shi-Tomasi');
plotpoints(I,J);
subplot(2,3,4);
[I,J]=select2(RES2,20);
im(CONESD);
title('Shi-Tomasi');
plotpoints(I,J);

RES = response(CONESG,1,2,'Harris-Plessey');
RES2 = response(CONESD,1,2,'Harris-Plessey');

RES = nonmax(RES,20);
RES2 = nonmax(RES2,20);
subplot(2,3,2);
[I,J]=select2(RES,20);
im(CONESG);
title('Harris');
plotpoints(I,J);
subplot(2,3,5);
[I,J]=select2(RES2,20);
im(CONESD);
title('Harris');
plotpoints(I,J);

RES = response(CONESG,1,2,'Noble');
RES2 = response(CONESD,1,2,'Noble');

RES = nonmax(RES,20);
RES2 = nonmax(RES2,20);
subplot(2,3,3);
[I,J]=select2(RES,20);
im(CONESG);
title('Noble');
plotpoints(I,J);
subplot(2,3,6);
[I,J]=select2(RES2,20);
im(CONESD);
title('Noble');
plotpoints(I,J);

%%
CONESG=double(imread('paysage1.pgm'));
RES = response(CONESG,1,2,'Shi-Tomasi');

CONESD=double(imread('paysage2.pgm'));
RES2 = response(CONESD,1,2,'Shi-Tomasi');

RES = nonmax(RES,20);
RES2 = nonmax(RES2,20);
figure;
subplot(2,3,1);
[I,J]=select2(RES,20);
im(CONESG);
title('Shi-Tomasi');
plotpoints(I,J);
subplot(2,3,4);
[I,J]=select2(RES2,20);
im(CONESD);
title('Shi-Tomasi');
plotpoints(I,J);

RES = response(CONESG,3,2,'Harris-Plessey');
RES2 = response(CONESD,3,2,'Harris-Plessey');

RES = nonmax(RES,20);
RES2 = nonmax(RES2,20);
subplot(2,3,2);
[I,J]=select2(RES,20);
im(CONESG);
title('Harris');
plotpoints(I,J);
subplot(2,3,5);
[I,J]=select2(RES2,20);
im(CONESD);
title('Harris');
plotpoints(I,J);

RES = response(CONESG,1,2,'Noble');
RES2 = response(CONESD,1,2,'Noble');

RES = nonmax(RES,20);
RES2 = nonmax(RES2,20);
subplot(2,3,3);
[I,J]=select2(RES,20);
im(CONESG);
title('Noble');
plotpoints(I,J);
subplot(2,3,6);
[I,J]=select2(RES2,20);
im(CONESD);
title('Noble');
plotpoints(I,J);

%%
CONESG=double(imread('paysage1.pgm'));
subplot(2,3,1);
RES = response(CONESG,1,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('1,2');
axis image;
subplot(2,3,4);
RES = response(CONESG,2,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('2,2');
axis image;
subplot(2,3,2);
RES = response(CONESG,1,0.5,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('1,0.5');
axis image;
subplot(2,3,5);
RES = response(CONESG,0.5,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('0.5,2');
axis image;
subplot(2,3,3);
RES = response(CONESG,3,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('3,2');
axis image;
subplot(2,3,6);
RES = response(CONESG,1,5,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('1,5');
axis image;
%%
CONESG=double(imread('paysage1.pgm'));
subplot(2,3,1);
RES = response(CONESG,1,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('1,2');
axis image;
subplot(2,3,4);
RES = response(CONESG,2,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('2,2');
axis image;
subplot(2,3,2);
RES = response(CONESG,1,0.5,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('1,0.5');
axis image;
subplot(2,3,5);
RES = response(CONESG,0.5,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('0.5,2');
axis image;
subplot(2,3,3);
RES = response(CONESG,3,2,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('3,2');
axis image;
subplot(2,3,6);
RES = response(CONESG,1,5,'Harris-Plessey');
im=exp(RES);
%im=(im-min(im(:)))/(max(im(:))-min(im(:)));
image(im);
title('1,5');
axis image;
