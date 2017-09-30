function newImage = filtrageGaussien(grayImage, size, sigma)
  newImage = grayImage;
  w = (size - 1)/2;
  sum = 0;
  for x = -w:w
    for y = -w:w
      value = 1 / (2 * pi * sigma^2) * exp(-(x^2+y^2)/(2 * sigma^2));
      F(x+w+1,y+w+1) = value;
      sum = sum + value;
    end
  end
  F = 1/sum * F;
  newImage = convolutionCustom(newImage, F);
end