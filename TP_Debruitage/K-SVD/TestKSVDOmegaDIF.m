% TestKSVDOmegaDIF - synthetic tests of the analysis K-SVD algorithm for 
% Omega_DIF. 
clc
clear
close all

% Set problem dimensions
n=5;
d=n^2; % signal dimension
r=4; % subspace dimension for each signal 
N=50000; % number of signals

% Generate analysis signals lying in r-dimensional nullspaces
Omega = GenerateOmegaDIF(n); % Omega_DIF
p=size(Omega,1); % number of atoms
[x,SuppTrue]=GenerateAnalysisSignals(Omega,d-r,N);
AvgCardTrue=mean(sum(SuppTrue));

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
    Iter1=75;
    OmegaInit=[];
    AtomUpdateType=1;
    [OmegaEst1(:,:,u),Xest1,Err1(:,u),CoSparsLevel1(:,u),DnErr1(:,u),OmegaRatio1(:,u),OmegaDist1(:,u)]=...
        AnalysisKSVD(xn,DimTar,2*d,Iter1,PursuitType,OmegaInit,AtomUpdateType,x,Omega);
    Iter2=25;
    OmegaInit=squeeze(OmegaEst1(:,:,u));
    AtomUpdateType=2;
    [OmegaEst2(:,:,u),Xest2,Err2(:,u),CoSparsLevel2(:,u),DnErr2(:,u),OmegaRatio2(:,u),OmegaDist2(:,u),]=...
        AnalysisKSVD(xn,DimTar,2*d,Iter2,PursuitType,OmegaInit,AtomUpdateType,x,Omega);
end

% Show results
Err=[Err1;Err2];
AvgCoSparsLevel=[CoSparsLevel1;CoSparsLevel2];
DnErr=[DnErr1;DnErr2];
OmegaRatio=[OmegaRatio1;OmegaRatio2];
figure
plot(Err(:,1),'-k')
hold on
plot(Err(:,2),'--k')
hold off
legend('Noise-free','Noisy - SNR=25')
xlabel('Iteration')
h2=ylabel('$\|\widehat{\textbf{X}}-\textbf{Y}\|_F/\sqrt{Rd}$');
set(h2,'interpreter','latex')
xlim([0,Iter1+Iter2+1])
figure
plot(AvgCoSparsLevel(:,1),'-k')
hold on
plot(AvgCoSparsLevel(:,2),'--k')
hold off
legend('Noise-free','Noisy - SNR=25')
xlabel('Iteration')
ylabel('Average cosparsity');
xlim([0,Iter1+Iter2])
ylim([20,35])
figure
plot((DnErr(:,2)).^2/sigma^2,'-k')
xlabel('Iteration')
h2=ylabel('$\|\widehat{\textbf{X}}-\textbf{X}\|_F^2/(Rd\sigma^2)$');
set(h2,'interpreter','latex')
xlim([0,Iter1+Iter2+1])
figure
plot(100*OmegaRatio(:,1),'-k')
hold on
plot(100*OmegaRatio(:,2),'--k')
hold off
legend('Noise-free','Noisy - SNR=25')
xlabel('Iteration')
ylabel('Percent recovered rows')
xlim([0,Iter1+Iter2+1])
ylim([-1,101])