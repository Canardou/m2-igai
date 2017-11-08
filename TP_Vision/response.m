function [R]=response(Im,SigmaDerivation,SigmaIntegration,Method)
    [d1,di,dj,d4,d5,d6] = gaussmask2(SigmaDerivation);
    
    DerivI = conv2(Im,di,'same');
    DerivJ = conv2(Im,dj,'same');
    mu11 = DerivI.^2;
    mu22 = DerivJ.^2;
    mu12 = DerivI.*DerivJ;
    
    Smooth = gaussmask2(SigmaIntegration);
    UniformSmooth = ones(size(Smooth))/numel(Smooth);
    mu11 = conv2(mu11,Smooth,'same');
    mu22 = conv2(mu22,Smooth,'same');
    mu12 = conv2(mu12,Smooth,'same');
    
    shitmu11 = conv2(mu11,UniformSmooth,'same');
    shitmu12 = conv2(mu12,UniformSmooth,'same');
    
    if strcmp(Method,'Harris-Plessey')
        R = mu11.*mu22-mu12.^2-0.04*(mu11+mu22).^2;
    elseif strcmp(Method,'Noble')
        R = 2*(mu11.*mu22-mu12.^2)./(mu11+mu22+10^-15);
    elseif strcmp(Method,'Shi-Tomasi')
        R = (shitmu11 + shitmu12 - sqrt((shitmu11-shitmu12).^2+4*shitmu12.^2))/2;
    end
end