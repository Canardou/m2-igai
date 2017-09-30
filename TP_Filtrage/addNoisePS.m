function newImage = addNoisePS(image, k)
  newImage = imageToGrayScale(image);
  [rows, columns] = size(newImage);
  n = rand(rows,columns);
  newImage(n < k) = 0;
  newImage(n > 1-k) = 255;
end
