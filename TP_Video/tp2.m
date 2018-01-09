im1=double(rgb2gray(imread('TP02I01.jpg')))-128;
im2=double(rgb2gray(imread('TP02I02.jpg')))-128;

%% Découpage en bloc
%
Mat = {};
U = 0:7;
V = 0:7;
for u = U
    for v = V
        Mat{u*8+v+1} = @(x,y) c(u)*c(v)/4*sum(sum(cos((2*x+1)*u*pi/16)*cos((2*y+1)*v*pi/16)));
    end
end

Mat = reshape(Mat,[8 8])';

%%
IM1 = zeros(size(im1));
IM2 = zeros(size(im2));

for Bx = 1:size(im1,1)/8
    for By = 1:size(im1,2)/8
        StartX = (Bx-1)*8;
        StartY = (By-1)*8;
        for u = 1:8
            for v = 1:8
                IM1(StartX+u,StartY+v) = Mat{u,v}(StartX+u-1,StartY+v-1)*im1(StartX+u,StartY+v);
                IM2(StartX+u,StartY+v) = Mat{u,v}(StartX+u-1,StartY+v-1)*im2(StartX+u,StartY+v);
            end
        end
    end
end

%%

im1r = zeros(size(im1));
im2r = zeros(size(im2));

Matr = {};
for u = U
    for v = V
        Matr{u*8+v+1} = @(x,y) 1/4*sum(sum(c(u)*c(v)*cos((2*x+1)*u*pi/16))*cos((2*y+1)*v*pi/16));
    end
end

Matr = reshape(Matr,[8 8])';

for Bx = 1:size(im1,1)/8
    for By = 1:size(im1,2)/8
        StartX = (Bx-1)*8;
        StartY = (By-1)*8;
        for u = 1:8
            for v = 1:8
                im1r(StartX+u,StartY+v) = Mat{u,v}(StartX+u-1,StartY+v-1)*IM1(StartX+u,StartY+v);
                im2r(StartX+u,StartY+v) = Mat{u,v}(StartX+u-1,StartY+v-1)*IM2(StartX+u,StartY+v);
            end
        end
    end
end

figure;
subplot(3,2,3);
imagesc(log(abs(IM1))+1);
axis image
subplot(3,2,4)
imagesc(log(abs(IM2))+1);
axis image
subplot(3,2,1);
imshow(im1/255+0.5);
subplot(3,2,2)
imshow(im2/255+0.5);
subplot(3,2,5);
imshow(im1r+0.5);
subplot(3,2,6)
imshow(im2r+0.5);

function r=c(a)
    if a == 0
        r = 1/sqrt(2);
    else
        r = 1;
    end
end