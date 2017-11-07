function I2=rect(I1)
%I2=rect(I1);
%NORMALISATION entre 0 et 255 d'une matrice
%
NiveauMax=max(max(I1));
NiveauMin=min(min(I1));
I2=round((I1-NiveauMin)/(NiveauMax-NiveauMin)*255);


