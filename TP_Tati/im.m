function [h] = im(M)
%[h] = im(M)
%AFFICHAGE d'une image
%
%Ex: im(I);
%
%Le parametre en sortie (h) est optionnel; c'est le handle vers l'objet image
%
if nargin~=1, error('Nombre de parametres en entree incorrect'); end
if nargout>1, error('Nombre de parametres en sortie incorrect'); end

figure(gcf);
colormap(gray(256));
hh=image(M);
axis image;
%axis off;
drawnow;
if nargout==1, h=hh; end

