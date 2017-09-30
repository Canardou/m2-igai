function resultMatrix = convolutionCustom(X,Y)
  resultMatrix = X;
  w = ceil(size(Y,1) / 2 - 1);
  for i = 1+w:size(X,1)-w
    for j = 1+w:size(X,2)-w
      sum = 0;
      for m =  -w:w
        for n = -w:w
          sum = sum + double(X(i - m, j - n)) * double(Y(m + w + 1, n + w + 1));
        end
      end
      resultMatrix(i,j) = int16(sum);
    end
  end
end