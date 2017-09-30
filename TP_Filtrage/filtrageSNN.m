function newImage = filtrageSNN(grayImage, M)
  [rows, columns] = size(grayImage);
  M_half = (M - 1)/2;
  newImage = grayImage;
  for x = 1+M_half:rows-M_half
    for y = 1+M_half:columns-M_half
      value = int16(grayImage(x,y));
      kValues = [];
      for i = -M_half:M_half
        for j = 0:M_half
          if (( i ~= 0 || j ~=0 ) && i + j > 0) || (i + j == 0 && i < j)
            if abs(int16(grayImage(x+i,y+j))-value) > abs(int16(grayImage(x-i,y-j))-value)
              kValues = [kValues,grayImage(x-i,y-j)];
            else
              kValues = [kValues,grayImage(x+i,y+j)];
            end
          end
        end
      end
      newImage(x,y) = mean(kValues);
    end
  end
end