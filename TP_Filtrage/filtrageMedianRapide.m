function newImage = filtrageMedianRapide(grayImage, wx, wy)
  [rows, columns] = size(grayImage);
  df = floor(wx * wy / 2);
  for j = ceil(wy/2):ceil((columns-wy)/2)
    H = zeros(256,1);
    for x = 1:wx
      for y = 1:wy
        H(grayImage(x,y+j)) = H(grayImage(x,y+j)) + 1;
      end
    end
    M = 0;
    nM = 0;
    tot = 0;
    for i = 1:256
      if H(i) > 0
        tot = tot + H(i);
      end
      nM = tot;
      if tot >= df
        M = i;
        nM = tot - H(i);
        break
      end
    end
    
    newImage(1,j)=M;
    
    for i = ceil(wx/2):ceil(columns-wx/2)
      for k = 1:wy
        H(grayImage(i-1,k)) = H(grayImage(i-1,k)) - 1;
        if grayImage(i-1,k) < H(nM)
          nM = nM - 1;
        end
        
        H(grayImage(i+wx,k)) = H(grayImage(i+wx,k)) + 1;
        if grayImage(i,k) < H(nM)
          nM = nM + 1;
        end
      end
      if nM > df
        while true
          M = M - 1;
          nM = nM - H(M);
          if nM <= df
            break
           end
        end
      else
        while H(nM) + nM <= df
          nM = nM + H(M);
          M = M + 1;
        end
      end
      newImage(i,j)=M;
    end
  end
end