function px = calculPuissance(image)
  [n, m] = size(image);
  newImage = image.^2;
  px = mean2(newImage);
end