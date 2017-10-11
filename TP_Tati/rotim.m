function I2=rotim(I1,Angle,lCentre,cCentre);
%I2=rotim(I1,Angle,lCentre,cCentre);

M1=[cos(Angle), sin(Angle), lCentre
   -sin(Angle), cos(Angle)  , cCentre
   0         , 0           , 1      ];
M2=[1, 0, -lCentre
    0, 1, -cCentre
    0, 0, 1       ];
Rot=M1*M2;

[l,c]=size(I1);
%Coordonnees des coins de l'image
% (dans la suite, on travaille en colonne,ligne)
Coins=[1,c,c,1 ; 1,1,l,l; 1 1 1 1];
% Calcul des images des coins de l'image
ImCoins=Rot*Coins; ImCoins=ImCoins(1:2,:);
%Calcul du rectangle englobant l'image transformee
cmin=min(ImCoins(1,:));
cmax=max(ImCoins(1,:));
lmin=min(ImCoins(2,:));
lmax=max(ImCoins(2,:));
%On decide que l'image resultat aura la meme taille que l'image initiale
%(d'autres choix sont possibles...)
%On commence par calculer les facteurs d'echelle
%(voir rectification epipolaire vue en cours).
au=(l-1)/(lmax-lmin);
av=(c-1)/(cmax-cmin);
%On souhaite n'avoir qu'un facteur d'echelle (les rapports de longueurs
%doivent etre conserves) et on ne veut rien perdre de l'image
a=min(au,av); au=a; av=a;
bu=1-au*lmin;
bv=1-av*cmin;
T=[av,0,bv ; 0,au,bu ; 0,0,1];
%Modification de la transformation
Rot=T*Rot;
%Calcul de la transformation inverse image resultat -> image initiale
InvRot=inv(Rot);

%Calcul de l'image resultat sans boucle
I2=255*ones(l,c); %pour avoir un fond blanc
%Obtention des coordonnes de tous les pixels de l'image
[C,L]=meshgrid(1:c,1:l);
P1=[C(:)';L(:)';ones(1,l*c)];
%Calcul des antecedents
P2=InvRot*P1; P2=P2(1:2,:);
%On ignore les antecedents qui ne sont pas dans l'image
IndBons=find(P2(1,:)>0 & P2(1,:)<=c & P2(2,:)>0 & P2(2,:)<=l);
%Calcul des niveaux de gris par interpolation bicubique
IndLin=sub2ind([l,c],P1(2,IndBons),P1(1,IndBons));
I2(IndLin)=round(interp2(C,L,I1,P2(1,IndBons),P2(2,IndBons),'cubic'));
%On s'occupe des pixels ou l'interpolation a echoue (bords)
I2(find(isnan(I2)))=255;

