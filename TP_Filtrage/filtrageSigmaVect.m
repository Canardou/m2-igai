function newImage = filtrageSigmaVect(grayImage, sigma, M)
  [rows, columns] = size(grayImage);
  grayImage = int16(grayImage);
  newImage = grayImage;
  M_half = (M - 1)/2;
  for x = 1+M_half:rows-M_half
    for y = 1+M_half:columns-M_half
      value = grayImage(x,y);
      smallMatrix = grayImage(x-M_half:x+M_half,y-M_half:y+M_half);
      sValues = smallMatrix(abs(value-smallMatrix)<sigma);
      if size(sValues) == 0
         sValues = reshape(smallMatrix,[M*M,1]);
      end
      newImage(x,y) = mean(sValues);
    end
  end
end