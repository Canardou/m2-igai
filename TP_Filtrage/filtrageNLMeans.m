function newImage = filtrageNLMeans(grayImage, neighborhoodSize, sigma)
  [n, m] = size(grayImage);
  grayImage = double(grayImage);
  newImage = grayImage;
  nSize = neighborhoodSize*neighborhoodSize;
  w = (neighborhoodSize-1)/2;
  % for each pixels store neighborhood (do not treat border)
  nMatrix = zeros(n,m,nSize);
  for i = 1+w:n-w
      for j = 1+w:m-w
          tmp = grayImage(i-w:i+w,j-w:j+w);
          nMatrix(i,j,:) = reshape(tmp,1,1,nSize);
      end
  end
  h = waitbar(0,'Initializing waitbar...');
  % filter for each pixel each other pixel
  for i = 1+w:n-w
      for j = 1+w:m-w
          normalisation = 0.0;
          newImage(i,j) = 0;
          for k = 1+w:n-w
              for l = 1+w:m-w
                m1 = nMatrix(i,j,:);
                m2 = nMatrix(k,l,:);
                G = exp(-(norm(m1(:)-m2(:)))^2/(2*sigma^2));
                normalisation = double(normalisation) + G;
                newImage(i,j) = double(newImage(i,j) + G * double(grayImage(k,l)));
              end
          end
          newImage(i,j) = double(newImage(i,j) / normalisation);
          waitbar(i/n,h,'Calculating...')
      end
  end
  close(h)
end