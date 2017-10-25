function [X,S]=GenerateAnalysisSignals(Omega,RankNull,N,ShowFigures)
%GenerateAnalysisSignals generates analysis signals lying in r-dimensional 
%nullspaces corresponding to a given analysis dictionary.
%  [X,S]=GenerateAnalysisSignals(Omega,RankNull,N,ShowFigures)
%  ========================================================================
%  Input:
%  Omega    - analysis dictionary.
%  RankNull - subspace dimension for the analysis signals.
%  N        - number of signals.
%
%  Optional input:
%  ShowFigures - flag for displaying figures (default - 0, do not show)
%  ========================================================================
%  Output:
%  X - matrix containing the generated analysis signal (in its columns).
%  S - matrix containing 1's for co-supports of the generated signals.
%  ========================================================================
%  Tomer Peleg
%  Department of Electrical Engineering
%  Technion, Haifa 32000 Israel
%  tomerfa@tx.technion.ac.il
%
%  October 2012
%  ========================================================================
if nargin<4
    ShowFigures=1;
end
[p,d]=size(Omega);
n=sqrt(d);

% Choosing Lambda
X=zeros(d,N);
h=waitbar(0,'Gathering signals ...'); 
for k=1:N
    if rem(k,10)==0
        waitbar(k/N);
    end
    List=randperm(p);
    Q=ComputeOrthoSet(Omega(List,:));
    Q=Q(1:RankNull,:);
    x=randn(d,1);
    X(:,k)=(eye(d)-Q'*Q)*x;
end
close(h)
X=normcols(X);
S=abs(Omega*X)<1e-6;

% Present several examples
if ShowFigures && floor(n)==ceil(n)
    h1=figure;
    DisplayOmega(Omega,h1);
    IMAGE=ones(1,20*n+20+1);
    for j=1:1:10
        ROW=ones(n,1);
        for k=1:1:20
            pos=randperm(N);
            pos=pos(1);
            ROW=[ROW, reshape(X(:,pos),n,n),ones(n,1)];
        end
        IMAGE=[IMAGE; ROW; ones(1,20*n+20+1)];
    end
    figure,imagesc(IMAGE); colormap(gray(256));
    axis image; axis off;
end

% Create an histogram of the co-sparsity levels
if ShowFigures
    figure(3); clf; 
    h=hist(sum(S),1:1:p); 
    hist(sum(S),1:1:p); 
    hold on; 
    plot([RankNull RankNull],[0 max(h)]); 
    xlabel('cosparsity l');
    ylabel('# of signals'); 
end