function newImage = filtrageMinMax(grayImage, M)
  [rows, columns] = size(grayImage);
  M_half = (M - 1)/2;
  newImage = grayImage;
  for x = 1+M_half:rows-M_half
    for y = 1+M_half:columns-M_half
      Min = 255;
      Max = 0;
      for i = -M_half:M_half
        for j = -M_half:M_half
          if i ~= 0 || j ~= 0
            Min = min(Min, grayImage(x+i,y+j));
            Max = max(Max, grayImage(x+i,y+j));
          end
        end
      end
      if grayImage(x,y) < Min
          newImage(x,y) = Min;
      elseif grayImage(x,y) > Max
          newImage(x,y) = Max;
      end
    end
  end
end