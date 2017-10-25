function [ C ] = multrows(A,b)

C=spdiags(b,0,length(b),length(b))*A;

end