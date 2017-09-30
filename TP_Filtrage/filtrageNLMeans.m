function newImage = filtrageNLMeans(grayImage, M)
  [n, m] = size(grayImage);
  newImage = grayImage;
  
  h = sqrt(2)*std(double(f(:)));
  M_half = (M-1)/2;
  num = 1;
  for i = 1+M_half:n-M_half
      for j = 1+M_half:m-M_half
          N(num, :) = rshape( f(i-M_half:i+M_half, j-M_half:j+M_half), [1, M*M]);
          num = num + 1;
      end
  end
  
  for i = 1+M_half:n-M_half
      for j = 1+M_half:m-M_half
          cur = reshape( f(i-M_half:i+M_half, j-M_half:j+M_half), [1, M*M] );
          Z = 0;
          for k = 1:num-1
              w = exp( -(norm(cur - N(k, :))^2) / (h^2) );
              g(i, j) = g(i, j) + N(k,(M^2+1)/2)*w;
              Z = Z + w;
          end
          g(i, j) = g(i,j)/Z;
      end
  end
end