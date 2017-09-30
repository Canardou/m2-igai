function newImage = filtrageSigma(grayImage, sigma, M)
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
          if i~=0 || j~=0
              if abs(grayImage(x+i, y+j) - value) <= sigma
                kValues = [kValues, grayImage(x+i, y+j)];
              end
          end
        end
      end
      if size(kValues) == 0
        for i = -M_half:M_half
            for j = -M_half:M_half
                if i~=0 || j~=0
                    kValues = [kValues, grayImage(x+i, y+j)];
                end
            end
        end
      end
      newImage(x,y) = mean(kValues);
    end
  end
end