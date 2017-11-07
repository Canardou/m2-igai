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
CONESG=double(imread('conesgauche.pgm'));
RES = response(CONESG,1,2,'Shi-Tomasi');
figure;
im(RES);

RES = nonmax(RES,5);
figure;
[I,J]=select1(RES,50);
im(CONESG);
plotpoints(I,J);