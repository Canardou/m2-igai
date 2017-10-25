function [Xest,Sest,Err,Q]=RankBGP(Y,Omega,RankTar,PursuitType)
%RankBGP - Backward Greedy Pursuit, rank constrained
%  [Xest,Sest,Err,Q]=RankBGP(Y,Omega,RankTar,PursuitType) 
%  Approximates the solution to the rank-based analysis pursuit problem:
% 
%  min  |Y - X|_2  s.t.  rank(Omega_Lambda)=d-r
%   X
%  ========================================================================
%  Input:
%  Y           - signal (possibly corrupted by additive noise)
%  Omega       - analysis dictionary (the function assumes normalized rows).
%  RankTar     - target co-rank (d-r)
%  PursuitType - which pursuit method to apply: 0 - THR, 1 - BG, 2 - OBG. 
%                OBG uses a greedy OOMP-like method that projects on each 
%                possible atom and chooses the one that does best in terms 
%                of energy reduction.
%  ========================================================================
%  Output:
%  Xest - estimated signal.
%  Sest - co-support, represented by a logical array containing 1's for the 
%         rows selected by BGP (rows in Omega that Xest is orthogonal to).
%  Err  - residual error ||Y-Xest||_2.
%  Q    - matrix containing (in its rows) the orthogonal basis for the rows 
%         in Omega indexed in the co-support.
%  ========================================================================
%  Tomer Peleg
%  Department of Electrical Engineering
%  Technion, Haifa 32000 Israel
%  tomerfa@tx.technion.ac.il
%
%  October 2012
%  ========================================================================
d=size(Omega,2);
Sest=abs(Omega*Y)<1e-8;
if sum(Sest>0)
    Q=ComputeOrthoSet(Omega(Sest>0,:));
    Xest=(eye(d)-Q'*Q)*Y;
    Err=norm(Xest-Y);
else
    Xest=Y;
    Q=[];
end
while size(Q,1)<RankTar
    [q,Xest,Sest]=AddOneElement(Omega,Q,Xest,Sest,Y,PursuitType);
    Err=norm(Xest-Y);
    Q=[Q;q];
end