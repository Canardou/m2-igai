function result = erreurQuadratiqueMoyenne(X,Y)
  result = 0;
  for i = 1:size(X,1)
    for j = 1:size(X,2)
      result = result + (double(Y(i,j)) - double(X(i,j)))^2;
    end
  end
  result = result / (double(size(X,1)) * double(size(X,2)));
end