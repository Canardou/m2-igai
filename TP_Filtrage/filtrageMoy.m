function newImage = filtrageMoy(grayImage, M)
  newImage = grayImage;
  F = 1/(M*M) * ones(M);
  newImage = convolutionCustom(newImage, F);
end