function newImage = imageToGrayScale(image)
  %[rows, columns, channels] = size(image);
  red = image(:, :, 1);
  green = image(:, :, 2);
  blue = image(:, :, 3);
  newImage = .2126*double(red) + .7152*double(green) + .0722*double(blue);
  newImage = uint8(newImage);
end