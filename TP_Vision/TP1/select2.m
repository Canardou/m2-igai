function [I,J]=select2(R,NbPoints)
    sorted = sort(R(:),'descend');
    top = sorted(NbPoints);
    [I,J] = find(R>=top,NbPoints);
end

