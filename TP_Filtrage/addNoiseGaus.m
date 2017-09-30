function newImage = addNoiseGaus(image, sigma)
  [rows, columns, ~] = size(image);
  n = int16(sigma*randn(rows,columns));
  newImage = uint8(int16(imageToGrayScale(image)) + n);
end