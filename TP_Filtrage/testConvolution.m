A=[1 2 3; 4 5 6; 7 8 9];
B=[-1 -2 -1; 0 0 0; 1 2 1];
R=[-13 -20 -17; -18 -24 -18; 13 20 17]

R2=convolutionCustom(A,B)

rmse(R,R2)

A=[1 1 1 1; 1 1 1 1; 1 1 5 1; 1 1 1 2];
B=[1/9 1/9 1/9; 1/9 1/9 1/9; 1/9 1/9 1/9];
R=[0   1   1   0;
   1   1.5   1   1;
   1   1   2   1;
   0   1   1   1]

R2=convolutionCustom(A,B)

rmse(R,R2)