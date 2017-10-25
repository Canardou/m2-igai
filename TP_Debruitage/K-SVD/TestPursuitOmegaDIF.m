% TestPursuitOmegaDIF - synthetic tests of the analysis pursuit methods for 
% Omega_DIF. 
clc
clear
close all

% Set problem dimensions
n=5; 
d=n^2; % signal dimension
r=4; % subspace dimension for each signal 
N=1000; % number of training signals

% Generate analysis signals lying in r-dimensional nullspaces
Omega = GenerateOmegaDIF(n); % Omega_DIF 
p=size(Omega,1); % number of atoms
[x,SuppTrue]=GenerateAnalysisSignals(Omega,d-r,N);

% Add noise and test various pursuit methods
sigma=0.2/sqrt(d);
display(['sigma=',num2str(sigma)])
v=sigma*randn(size(x));
xn=x+v;
disp(['SNR=',num2str(mean(sum((x).^2)./sum((x-xn).^2)))]);
%matlabpool(2)
for k=1:N %parfor
    G=Omega(SuppTrue(:,k)>0,:);
    Pk=eye(d)-pinv(G)*G;
    zoracle(:,k)=Pk*xn(:,k);
    DnErrOracle(k)=(norm(zoracle(:,k)-x(:,k))/(sigma*sqrt(d)))^2;
end
%matlabpool close;
RelDenoisingOracle=(norm(zoracle-x,'fro')/(sigma*sqrt(d*N)))^2;
TargetFuncOracle=(norm(zoracle-xn,'fro')/(sigma*sqrt(d*N)))^2;

RankTarVec=d-r-6:d-r+1;
%matlabpool(2)
for ll=1:length(RankTarVec)
    RankTar=RankTarVec(ll);
    for k=1:N %parfor
        [z1(:,k),SuppEst1(:,k),Err1(k),Q1] = RankBGP(xn(:,k),Omega,RankTar,1);
        DnErr1(k)=(norm(z1(:,k)-x(:,k))/(sigma*sqrt(d)))^2;
        [z2(:,k),SuppEst2(:,k),Err2(k),Q2] = RankBGP(xn(:,k),Omega,RankTar,2);
        DnErr2(k)=(norm(z2(:,k)-x(:,k))/(sigma*sqrt(d)))^2;
    end
    TargetFuncBGRank(ll)=(norm(z1-xn,'fro')/(sigma*sqrt(d*N)))^2;
    TargetFuncOBGRank(ll)=(norm(z2-xn,'fro')/(sigma*sqrt(d*N)))^2;
    RelDenoisingBGRank(ll)=(norm(z1-x,'fro')/(sigma*sqrt(d*N)))^2;
    RelDenoisingOBGRank(ll)=(norm(z2-x,'fro')/(sigma*sqrt(d*N)))^2;
    display(['Subspace Dimension=',num2str(d-RankTar)])
    display('--------------------')
    display(['BG pursuit: target function=',num2str(TargetFuncBGRank(ll))])
    display(['OBG pursuit: target function=',num2str(TargetFuncOBGRank(ll))])
    display(['BG pursuit: relative denoising error=',num2str(RelDenoisingBGRank(ll))])
    display(['OBG pursuit: relative denoising error=',num2str(RelDenoisingOBGRank(ll))])   
end
%matlabpool close;
figure(4),clf
plot(d-fliplr(RankTarVec),fliplr(TargetFuncBGRank),'k','LineWidth',2); hold on;
plot(d-fliplr(RankTarVec),fliplr(TargetFuncOBGRank),'k--','LineWidth',2);
plot(d-fliplr(RankTarVec),TargetFuncOracle*ones(1,length(RankTarVec)),'k:','LineWidth',2); hold off;
xlabel('Subspace Dimension'); 
h2=ylabel('$\|\widehat{\textbf{X}}-\textbf{Y}\|_F^2/(Rd\sigma^2)$');
set(h2,'interpreter','latex')
legend({'BG','OBG','Oracle'},1);
xlim([r-1.1,r+6.1])
ylim([0,1.35])
figure(5),clf
plot(d-fliplr(RankTarVec),fliplr(RelDenoisingBGRank),'k','LineWidth',2); hold on; 
plot(d-fliplr(RankTarVec),fliplr(RelDenoisingOBGRank),'k--','LineWidth',2);
plot(d-fliplr(RankTarVec),RelDenoisingOracle*ones(1,length(RankTarVec)),'k:','LineWidth',2); hold off;
xlabel('Subspace Dimension'); 
ylabel('Relative Denoising Error');
legend({'BG','OBG','Oracle'},1);
xlim([r-1.1,r+6.1])
ylim([0,1.35])

EtaThrVec=0.5:0.1:1.5;
%matlabpool(2)
for ll=1:length(EtaThrVec)
    ErrThr=EtaThrVec(ll)*sqrt(d)*sigma;
    for k=1:N %parfor
        [z3(:,k),SuppEst3(:,k),Err3(k),Q3] = ErrorBGP(xn(:,k),Omega,ErrThr,1);
        rank3(k)=size(Q3,1);
        [z4(:,k),SuppEst4(:,k),Err4(k),Q4] = ErrorBGP(xn(:,k),Omega,ErrThr,2);
        rank4(k)=size(Q4,1);
    end
    RelDenoisingBGErr(ll)=(norm(z3-x,'fro')/(sigma*sqrt(d*N)))^2;
    RelDenoisingOBGErr(ll)=(norm(z4-x,'fro')/(sigma*sqrt(d*N)))^2;
    display(['Error Threshold=',num2str(ErrThr)])
    display('-------------------')
    display(['BG pursuit: relative denoising error=',num2str(RelDenoisingBGErr(ll))])
    display(['OBG pursuit: relative denoising error=',num2str(RelDenoisingOBGErr(ll))])
end
%matlabpool close;
figure(6),clf
plot(EtaThrVec,RelDenoisingBGErr,'k','LineWidth',2); hold on; 
plot(EtaThrVec,RelDenoisingOBGErr,'k--','LineWidth',2);
plot(EtaThrVec,RelDenoisingOracle*ones(1,length(EtaThrVec)),'k:','LineWidth',2); hold off;
xlabel('\eta'); 
ylabel('Relative Denoising Error');
legend({'BG','OBG','Oracle'},2);
xlim([0.49,1.51])
ylim([0,1])