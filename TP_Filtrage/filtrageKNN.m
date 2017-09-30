function newImage = filtrageKNN(grayImage, k, M)
  [rows, columns] = size(grayImage);
  grayImage = int16(grayImage);
  newImage = grayImage;
  M_half = (M - 1)/2;
  for x = 1+M_half:rows-M_half
    for y = 1+M_half:columns-M_half
      value = grayImage(x,y);
      kValues = [];
      for i = -M_half:M_half
        for j = -M_half:M_half
          if i ~= 0 ||j ~= 0
              if size(kValues) < k
                kValues = [kValues, grayImage(x+i, y+j)];
              else
                kValues = sort(kValues);
                newValue = grayImage(x+i, y+j);
                if abs(value - kValues(1)) < abs(value - kValues(k))
                  if abs(value - newValue) < abs(value - kValues(k))
                      kValues(k) = newValue;
                  end
                elseif abs(value - newValue) < abs(value - kValues(1))
                  kValues(1) = newValue;
                end
              end
          end
        end
      end
      newImage(x,y) = mean(kValues);
    end
  end
end