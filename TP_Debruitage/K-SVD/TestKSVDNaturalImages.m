% TestKSVDNaturalImages - learn analysis dictionary from noisy natural 
% image patches, and tests patch-based image denoising with the learned 
% dictionary.
clear
clc
close all

% Set patch dimensions
n=7;
d=n^2; % patches of size n-by-n

% Set parameters for dictionary training
N=20000; % number of training examples
DimTar=7; % target subspace dimension
p=n*(n+2); % number of atoms
IterTrain=20; %number of iterations
PursuitType=2; 
AtomUpdateType=3;
ImNames={'house'}; %{'lena','barbara','boats','house','peppers256'};
for j=1:length(ImNames)
    % Load image
    ImName=ImNames{j}
    I=imread(['.\images\',ImName,'.png']);
    I=double(I);
    X=im2col(I,[n,n],'sliding');
    SigmaVec=5;
    for k=1:length(SigmaVec)
        % Add noise
        sigma=SigmaVec(k);
        In=I+randn(size(I))*sigma;
        PSNRnoisy=10*log10(255.^2/mean((In(:)-I(:)).^2));
        clear results;
        Xn=im2col(In,[n,n],'sliding');
        Xdn=zeros(size(Xn));
        
        % Create training data
        Std0=1.15*sigma;
        Std1=1.5*sigma;
        Idx0=find(std(Xn)<Std0);
        Xdn(:,Idx0)=repmat(mean(Xn(:,Idx0)),d,1);
        NumPatches(1)=length(Idx0);
        DenoisingError(1)=norm(Xdn(:,Idx0)-X(:,Idx0),'fro')/sqrt(d*length(Idx0));
        CoSparsityLevel(1)=d;
        IdxTrain=find(std(Xn)>Std1);
        IdxN=randperm(length(IdxTrain));
        pos=IdxTrain(IdxN(1:min(N,length(IdxTrain))));
        Xntrain=Xn(:,pos);
        disp(['Number of examples: ',num2str(size(Xntrain,2))]);
        Xtrain=X(:,pos);
        
        % Show patch examples
        N1=20;
        count=1;
        IMAGE=zeros(1,1+(n+1)*N1);
        for ii=1:N1
            ROW=zeros(n,1);
            for jj=1:N1
                pos=randperm(size(Xtrain,2));
                ROW=[ROW, reshape(Xtrain(:,pos(1)),[n,n]), zeros(n,1)];
                count=count+1;
            end
            IMAGE=[IMAGE; ROW; zeros(1,1+(n+1)*N1)];
        end
        figure,imagesc(IMAGE); axis image; axis off; colormap(gray(256));
        
        % Train analysis dictionary
        OmegaInit=[];
        Omega=AnalysisKSVD(Xntrain,DimTar,p,IterTrain,PursuitType,OmegaInit,AtomUpdateType,Xtrain);            
        
        % Denoise image using trained Omega
        Idx1=find(std(Xn)>=Std0);
        Xn1=Xn(:,Idx1);
        clear Xn;
        X1=X(:,Idx1);
        DCn=mean(Xn1);
        Xn1=Xn1-repmat(DCn,d,1);
        Xdn1=zeros(size(Xn1));
        CoSdn1=false(p,size(Xn1,2));
        ErrThr=1.15*sqrt(d)*sigma;
        %matlabpool(2);
        for l = 1:size(Xn1,2) %parfor
            [Xdn1(:,l),CoSdn1(:,l)] = ErrorBGP(Xn1(:,l),Omega,ErrThr,2);
        end
        %matlabpool close;
        Xdn1=Xdn1+repmat(DCn,d,1);
        Xdn(:,Idx1)=Xdn1;
        DenoisingError(2)=norm(Xdn1-X1,'fro')/sqrt(d*size(Xn1,2));
        CoSparsityLevel(2)=mean(sum(CoSdn1));
        clear X1;
        clear Xn1;
        clear Xdn1;
        clear CoSdn1;
        NumPatches(2)=length(Idx1);
        TotalDenoisingError=norm(Xdn-X,'fro')/sqrt(d*size(Xdn,2));
        TotalCoSparsityLevel=sum(CoSparsityLevel.*NumPatches)/size(Xdn,2);      
        
        % Image denoising - average overlapping recovered patches
        [MM,NN]=size(In);
        Idn=col2imstep(Xdn,[MM NN],[n n]);
        cnt=countcover([MM NN],[n n],[1 1]);
        Idn=Idn./cnt;
        Idn=max(0,min(255,Idn));
        PSNRdn=10*log10(255.^2/mean((Idn(:)-I(:)).^2))
        figure,imshow(uint8(Idn),[0,255])
        title(['Recovered image: PSNR=',num2str(PSNRdn),'[dB]'])
        
        % Display learned Omega
        h1=figure;
        OmegaDisp=DisplayOmega(Omega,h1);
    end
end