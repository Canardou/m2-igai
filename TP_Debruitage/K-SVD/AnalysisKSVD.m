function [Omega,Xest,Err,CoSparsLevel,DnErr,OmegaRatio,OmegaDist] = AnalysisKSVD(X,DimTar,AtomNum,IterNum,PursuitType,...
    OmegaInit,AtomUpdateType,Xtrue,OmegaRef)
%AnalysisKSVD learns an analysis dictionaryan analysis dictionary using a 
%K-SVD-like method.
%  [Omega,Xest,Err,CoSparsLevel,DnErr,OmegaRatio,OmegaDist] = 
%  AnalysisKSVD(X,DimTar,NumAtoms,NumIter,PursuitType,OmegaInit,
%  AtomUpdateType,Xtrue,OmegaRef)
%  ========================================================================
%  Input:
%  X           - matrix of training signals (in its columns)
%  DimTar      - target dimension for each signal
%  AtomNum     - number of rows in trained Omega
%  IterNum     - number of training iterations
%  PursuitType - which pursuit method to apply: 1. (BG) - stop by co-rank
%                                               2. (OBG) - stop by co-rank
%  Optional input:
%  OmegaInit      - initial analysis operator to use
%  AtomUpdateType - which atom update to apply: 
%  1. Least eigenvector of relevant data covariance matrix (default)
%  2. Same as 1 + post-processing to encourage sparsity and zero-mean
%  3. Same as 1 + regularizing term to encourage pairwise orthogonality
%  Xtrue          - if X contains noisy signals, Xtrue are the noiseless 
%                   training signals
%  OmegaRef       - the true underlying Omega matrix if known
%  ========================================================================
%  Output:
%  Omega        - trained analyis opertor
%  Xest         - matrix of estimated noise-free signals (in its columns)
%  Performance evaluation (for each iteration): 
%  Err          - residual error (difference between Xest and X) 
%  CoSparsLevel - average co-sparsity level (for the  signal estimates) 
%  DnErr        - denoising error (difference between Xest and Xtrue)
%  OmegaRatio   - ratio of recovered atoms (with respect to OmegaRef) 
%  OmegaDist    - the distance between the trained Omega and OmegaRef
%  ========================================================================
%  Tomer Peleg
%  Department of Electrical Engineering
%  Technion, Haifa 32000 Israel
%  tomerfa@tx.technion.ac.il
%
%  October 2012
%  ========================================================================
[d,N]=size(X);
% Set input parameters
if nargin<6 || isempty(OmegaInit)
    OmegaInit=zeros(AtomNum,d);
    for j=1:AtomNum
        OmegaInit(j,:)=GenerateRandomRow(X);
    end
end
if nargin<7
    AtomUpdateType=1;
end
% Set other parameters
p=size(OmegaInit,1);
L=d-DimTar;
MinSigs=min(1000,0.1*N*L/p); % minimal number of relevant signals per atom
if AtomUpdateType==3
    M=5;
    alpha=1000;
else
    M=1;
end
% Initialize output parameters
Omega=OmegaInit;
Omega=normrows(Omega);
Xest=zeros(size(X));
Err=zeros(IterNum,1);
CoSparsLevel=zeros(IterNum,1); 
DnErr=zeros(IterNum,1);
OmegaRatio=zeros(IterNum,1);
OmegaDist=zeros(IterNum,1);
CoS=false(p,N);
h=figure;
%matlabpool(2); 
for i = 1:IterNum
    % =======> Analysis Pursuit
    for l = 1:size(X,2) %parfor
        [Xest(:,l),CoS(:,l)] = RankBGP(X(:,l),Omega,L,PursuitType);
    end
    Err(i)=norm(X-Xest,'fro')/sqrt(d*N); % training objective
    CoSparsLevel(i)=mean(sum(CoS)); % resulting average co-sparsity level
    fprintf('\nIteration %d / %d, error = %.3f, average co-sparsity = %.3f\n', i, IterNum, Err(i), CoSparsLevel(i));
    if nargin>=8
        DnErr(i)=norm(Xtrue-Xest,'fro')/sqrt(d*N); % denoising performance
        fprintf('                    denoising error = %.3f\n', DnErr(i));
    end 
    % =======> Update Omega
    NumSigs = sum(CoS,2);
    [NumSigs,IdxOmega]=sort(NumSigs,'descend');
    if AtomUpdateType==1 && nargin==9 && i<IterNum-9
        OmegaPrev=Omega;
    elseif AtomUpdateType==3
        CoEx=double(CoS)*(1-double(CoS))';
        Omega=Omega(IdxOmega,:);
        CoS=CoS(IdxOmega,:);
        CoEx=CoEx(IdxOmega,IdxOmega);
        E=eye(p);
    end
    for m=1:M
        for j=1:p
            Xs=X(:,CoS(j,:));  % the signals orthogonal to the current row
            CovX=Xs*Xs';
            if AtomUpdateType==3
                Idx1=find(E(j,:)==0);
                OmegaCW=repmat(sqrt(CoEx(Idx1,j)),1,d).*Omega(Idx1,:);
                RegTerm=alpha*(OmegaCW'*OmegaCW); % encourage orthogonality
            else
                RegTerm=1e-10*eye(d); % avoid singular matrix
            end
            if AtomUpdateType==1 && nargin==9 && size(Xs,2)<MinSigs && i<IterNum-9
                % Not enough signals in Xs - generate a new row
                Omega(j,:)=GenerateRandomRow(X);
                fprintf('Replaced row no. %d - not enough relevant signals\n', j);
            else
                % Enough signals in Xs - update row as least eigenvector
                [v,lambda]=eigs(CovX+RegTerm,1,'sm',struct('disp',0));
                Omega(j,:)=v';
            end
        end
    end
    if AtomUpdateType==1 && nargin==9 && i<IterNum-9
        % Find the rows which did not update in the last iteration
        cond1 = abs(diag(OmegaPrev*Omega'))>0.999;
        % Find two rows (at most) orthogonal to relatively few signals
        cond2 = zeros(p,1);
        cond2(IdxOmega(end-1:end)) = NumSigs(end-1:end)<0.7*median(NumSigs);
        cond = cond1 & cond2;
    else
        cond = zeros(p,1);
    end
    for j = 1:p
        if (any(abs(Omega(1:j-1,:)*Omega(j,:)') > 0.95)) || cond(j)
            % If row already appeared or does not update as it should - replace it
            Omega(j,:)=GenerateRandomRow(X);
            fprintf('Replaced row no. %d - already appeared or does not update as it should\n', j);
        elseif AtomUpdateType==2
            % Post-processing to encourage sparse atoms with zero-mean
            z1=abs(Omega(j,:));
            Omega(j,z1<0.1*max(z1))=0;
            if abs(mean(Omega(j,:)))<0.1*max(z1)
                Omega(j,abs(Omega(j,:))>0)=Omega(j,abs(Omega(j,:))>0)-mean(Omega(j,abs(Omega(j,:))>0));
            end
            Omega(j,:)=normrows(Omega(j,:));
        end
    end
    DisplayOmega(Omega,h);
    if nargin==9
        [OmegaDist(i),OmegaRatio(i)] = dictdist(Omega',OmegaRef'); %distance to OmegaRef
        fprintf('Distance to true dictionary = %.3f, percent recovered rows = %.2f\n',...
            OmegaDist(i), OmegaRatio(i)*100);
    end
end
%matlabpool close;