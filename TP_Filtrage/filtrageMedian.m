function newImage = filtrageMedian(grayImage, M)
  [rows, columns] = size(grayImage);
  newImage = grayImage;
  M_half = (M - 1)/2;
  for x = 1+M_half:rows-M_half
    for y = 1+M_half:columns-M_half
      H = [];
      for i = -M_half:M_half
        for j = -M_half:M_half
          H = [H, grayImage(x+i, y+j)];
        end
      end
      newImage(x,y) = median(H);
    end
  end
end