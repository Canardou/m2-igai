k = 4;
I = int16([255, 0, 8; 130, 5, 123; 5, 2, 4])
value = 5;
kValues = [];
for i = -1:1
for j = 0:1
  if (( i ~= 0 || j ~=0 ) && i + j > 0) || (i + j == 0 && i < j)
      I(i+2,j+2)
    if abs(I(i+2,j+2)-value) < abs(I(2-i,2-j)-value)
      kValues = [kValues,I(i+2,j+2)];
    else
      kValues = [kValues,I(2-i,2-j)];
    end
  end
end
end
kValues
mean(kValues)