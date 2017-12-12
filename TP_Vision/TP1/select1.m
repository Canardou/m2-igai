function [I,J]=select1(R,Percent)
    seuil = max(max(R))*Percent/100;
    [I,J] = find(R>seuil);
end

