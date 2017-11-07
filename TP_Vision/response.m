function [R]=response(Im,SigmaDerivation,SigmaIntegration,Method)
    [Smooth,d1,d2,d3,d4,d5] = gaussmask2(SigmaIntegration);
    [s,d6,d7,DerivII,DerivJJ,DerivIJ] = gaussmask2(SigmaDerivation);
    mu11 = conv2(conv2(Im,Smooth,'same'),DerivII,'same');
    mu22 = conv2(conv2(Im,Smooth,'same'),DerivJJ,'same');
    mu12 = conv2(conv2(Im,Smooth,'same'),DerivIJ,'same');
    [h, w] = size(Im);
    for i = 1:h
        for j = 1:w
            M = [mu11(i,j) mu12(i,j); mu12(i,j) mu22(i,j)];
            if strcmp(Method,'Harris-Plessey')
                R(i,j) = det(M)-0.04*trace(M)*trace(M);
            elseif strcmp(Method,'Noble')
                R(i,j) = 2*det(M)/(trace(M)+10^-15);
            elseif strcmp(Method,'Shi-Tomasi')
                a = M(1,1);
                b = M(1,2);
                c = M(2,1);
                R(i,j) = (a + c - sqrt((a-c)^2+4*b*b))/2;
            end
        end
    end
end