%% 1.
im1=double(imread('TP01I01GIF.ppm'));
REF=double(imread('TP01I01REF.ppm'));

EQM = sum(sum(sum((im1-REF).^2)))/(size(REF,1)*size(REF,2)*3);

%% 2.

m=double(zeros(256,256,3));
for i=1:256
    for j=1:256
        m(i,j,1)= 256-floor((i+j)/2);
        m(i,j,2)=i-1;
        m(i,j,3)=j-1;
    end
end

a=2;
b=2;
c=2;
N=2^(a+b+c);
lut = [];
for i=1:N
    lut(i,3)=(round(255/2^c)*mod(floor(i-1),2^c))+round(255/2^(c+1));
    lut(i,2)=(round(255/2^b)*mod(floor((i-1)/(2^c)),2^b))+round(255/2^(b+1));
    lut(i,1)=(round(255/2^a)*mod(floor((i-1)/(2^(b+c))),2^a))+round(255/2^(a+1));
end

m_lut = zeros(256,256,3);
m_dith = zeros(256,256,3);
m_dith_error = zeros(256,256,3);
for i=1:256
    for j=1:256
        [c,index] = min(sum(abs(double(squeeze(m(i,j,:))')-double(lut)),2));
        m_lut(i,j,:) = lut(index,:);
    end
end

figure(1);
imshow(uint8(m));

for i = 2:255
    for j = 2:255
        current = m(i,j,:);
        comp = repmat(transpose(current(:)), size(lut,1) ,1);
        eq = sum(abs(comp - lut),2);
        [mindif, ix] = min(eq);
        
        current=current(:);
        e = transpose(current) - (lut(ix,:));
        e = reshape(e,[1,1,3]);
        
        m(i,j+1,:)=m(i,j+1,:)+e*5/16;
        m(i+1,j,:)=m(i+1,j,:)+e*7/16;
        m(i+1,j+1,:)=m(i+1,j+1,:)+e*1/16;
        m(i+1,j-1,:)=m(i+1,j-1,:)+e*3/16;
        
        m_dith(i,j,:) = lut(ix,:);
    end
end

figure(2);
imshow(uint8(m_lut));
figure(3);
imshow(uint8(m_dith));
% 1.1
EQM2 = sum(sum(sum((m_lut-m).^2)))/(size(m,1)*size(m,2)*3);
% 1.2