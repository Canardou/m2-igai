function newImage = filtrageMoyVect(grayImage, M)
  newImage = grayImage;
  F = 1/(M*M) * ones(M);
  newImage = conv2(newImage, F, 'same');
end