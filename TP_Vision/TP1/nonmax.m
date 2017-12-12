function [R2]=nonmax(R1,WindowSize)
    [w, h] = size(R1);
    for i = WindowSize+1:w-WindowSize
        for j = WindowSize+1:h-WindowSize
            maxElem = max(max(R1(i-WindowSize:i+WindowSize,j-WindowSize:j+WindowSize)));
            if R1(i,j) < maxElem
                R2(i,j) = 0;
            else
                R2(i,j) = R1(i,j);
            end
        end
    end
end

