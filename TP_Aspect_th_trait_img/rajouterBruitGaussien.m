function newImage = rajouterBruitGaussien(image, sigma)
  n = sigma*randn(size(image));
  newImage = image + n;
end