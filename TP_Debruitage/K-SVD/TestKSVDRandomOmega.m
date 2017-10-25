% TestKSVDRandomOmega - synthetic tests of the analysis K-SVD algorithm for 
% a random Omega. 
clc
clear
close all

% Set problem dimensions
d=25; % signal dimension
l=d-4; % co-sparsity level for each signal
N=50000; % number of signals
p=2*d; % number of atoms

% Generate analysis signals with co-sparsity l
Omega=normrows(randn(p,d)); % random Omega
x=zeros(d,N);
SuppTrue=zeros(p,N);
h=waitbar(0,'Creating signals ...');
for i=1:N
    if rem(i,10)==0
        waitbar(i/N);
    end
    pos=randperm(p);
    SuppTrue(pos(1:l),i)=1; 
    Z=null(Omega(pos(1:l),:));
    a=randn(size(Z,2),1);
    x(:,i)=Z*a;
end;
close(h);
x=normcols(x);

% Add noise and test the analysis K-SVD algorithm
sigma_vec=[0,0.2/sqrt(d)];
for u=1:length(sigma_vec)
    sigma=sigma_vec(u);
    xn=x+sigma*randn(size(x));
    if sigma>0
        disp(['SNR=',num2str((norm(x,'fro')/norm(x-xn,'fro'))^2)]);
    end
    DimTar=4;
    PursuitType=2;
    % Train Omega
    Iter=100;
    OmegaInit=[];
    AtomUpdateType=1;
    [OmegaEst(:,:,u),Xest,Err(:,u),CoSparsLevel(:,u),DnErr(:,u),OmegaRatio(:,u),OmegaDist(:,u)]=...
        AnalysisKSVD(xn,DimTar,2*d,Iter,PursuitType,OmegaInit,AtomUpdateType,x,Omega);
end

% Show results
figure
plot(Err(:,1),'-k')
hold on
plot(Err(:,2),'--k')
hold off
legend('Noise-free','Noisy - SNR=25')
xlabel('Iteration')
h2=ylabel('$\|\widehat{\textbf{X}}-\textbf{Y}\|_F/\sqrt{Rd}$');
set(h2,'interpreter','latex')
xlim([0,Iter+1])
figure
plot(100*OmegaRatio(:,1),'-k')
hold on
plot(100*OmegaRatio(:,2),'--k')
hold off
legend('Noise-free','Noisy - SNR=25')
xlabel('Iteration')
ylabel('Percent recovered rows')
xlim([0,Iter+1])
ylim([-1,101])