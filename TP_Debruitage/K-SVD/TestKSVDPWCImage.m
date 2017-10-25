% TestKSVDPWCImage - learn analysis dictionary from noisy piece-wise 
% constant image patches, and tests patch-based image denoising with the 
% learned dictionary.
clear
clc
close all

% Set patch dimensions
n=5;
d=n^2; % patches of size n-by-n

% Set parameters for dictionary training
p=2*d; % number of atoms 
N=20000; % number of patch examples for training

% Load and display image
I=imread('.\images\PWCImage.png');
I=double(I);
figure,imshow(uint8(I),[0,255])
title('Noise-free image')
SigmaVec=5;
for j=1:length(SigmaVec)
    % Add noise
    sigma=SigmaVec(j);
    In=I+randn(size(I))*sigma;
    PSNRnoisy=10*log10(255.^2/mean((In(:)-I(:)).^2));
    figure,imshow(uint8(In),[0,255])
    title(['Noisy image: PSNR=',num2str(PSNRnoisy),'[dB]'])
    
    % Extract patches
    X=im2col(I,[n,n],'sliding');
    Xn=im2col(In,[n,n],'sliding');

    % Create training data
    StdThr=max(1.5*sigma,10);
    ids1=find(std(Xn)>StdThr);
    ids2=randperm(numel(ids1));
    pos=ids1(ids2(1:N));
    Xntrain=Xn(:,pos);
    Xtrain=X(:,pos);
    disp(['Number of examples: ',num2str(size(Xntrain,2))]); 

    % Show patch examples
    N1=20;
    N2=20;
    count=1; 
    IMAGE=zeros(1,1+(n+1)*N1); 
    for kk=1:1:N2
        ROW=zeros(n,1); 
        for jj=1:1:N1
            pos=randperm(size(Xtrain,2)); 
            ROW=[ROW, reshape(Xtrain(:,pos(1)),[n,n]), zeros(n,1)];
            count=count+1;
        end;
        IMAGE=[IMAGE; ROW; zeros(1,1+(n+1)*N1)];
    end
    figure,imagesc(IMAGE); axis image; axis off; colormap(gray(256)); 

    % Train Omega
    DimTar=4;
    Iter=75;
    OmegaInit=[];
    PursuitType=1;
    AtomUpdateType=1;
    Omega = AnalysisKSVD(Xntrain,DimTar,2*d,Iter,PursuitType,OmegaInit,AtomUpdateType,Xtrain);
    Iter=25;
    PursuitType=2;
    AtomUpdateType=2;
    Omega = AnalysisKSVD(Xntrain,DimTar,2*d,Iter,PursuitType,Omega,AtomUpdateType,Xtrain);
    
    % Evaluate performance on the training set
    XdnTrain = zeros(size(Xntrain));
    SuppDnTrain = false(p,size(Xntrain,2));
    %matlabpool(2);
    for l = 1:size(Xntrain,2) %parfor
        [XdnTrain(:,l),SuppDnTrain(:,l)] = RankBGP(Xntrain(:,l),Omega,d-DimTar,2);
    end
    %matlabpool close;
    TrainErr=norm(XdnTrain-Xntrain,'fro')/sqrt(d*size(Xntrain,2));
    TrainDnErr=norm(XdnTrain-Xtrain,'fro')/sqrt(d*size(Xntrain,2));
    TrainCoSparsityLevel=mean(sum(SuppDnTrain));
    
    % Denoise image using trained Omega
    Xdn = zeros(size(Xn));
    SuppDn = false(p,size(Xn,2));
    Err=zeros(1,size(Xn,2));
    DimDn=zeros(1,size(Xn,2));
    ErrThr=1.15*sqrt(d)*sigma;
    %matlabpool(2);
    for l = 1:size(Xn,2) %parfor
        [Xdn(:,l),SuppDn(:,l),Err(l),Q] = ErrorBGP(Xn(:,l),Omega,1.15*sqrt(d)*sigma,2);
        DimDn(l)=d-size(Q,1);
    end
    %matlabpool close;
    RepresentationError=norm(Xdn-Xn,'fro')/sqrt(d*size(Xn,2));
    DenoisingError=norm(Xdn-X,'fro')/sqrt(d*size(Xn,2));
    CoSparsityLevel=mean(sum(SuppDn));
    SubspaceDimension=mean(DimDn);

    % Image denoising - average overlapping recovered patches
    [MM,NN]=size(In);
    Idn=col2imstep(Xdn,[MM NN],[n n]);
    cnt=countcover([MM NN],[n n],[1 1]);
    Idn=Idn./cnt;
    Idn=max(0,min(255,Idn));
    PSNRdn=10*log10(255.^2/mean((Idn(:)-I(:)).^2));
    figure,imshow(uint8(Idn),[0,255])
    title(['Recovered image: PSNR=',num2str(PSNRdn),'[dB]'])
    
    % Display learned Omega
    h1=figure;
    OmegaDisp=DisplayOmega(Omega,h1);
end