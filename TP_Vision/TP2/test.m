[imgTmp,colorTmp]=imread('test.gif');

img = imgTmp + 1;

color = rgb2lab(colorTmp);

p = bayes(img,color,[1,1,10,10],[84,1,10,10],[130,1,10,10]);

treated = zeros(size(img));
for x = 1:size(img,2)
    for y = 1:size(img,1)
        proba = zeros(size(p));
        current = color(img(y,x),:);
        for p_ = 1:size(p,2)
            proba(p_) = p{p_}(current);
        end
        [maxnum,maxid] = max(proba(:));
        treated(y,x) = (maxid - 1)*0.5;
    end
end

subplot(2,1,1)
imshow(treated);
subplot(2,1,2)
imshow(imgTmp,colorTmp);axis image;

% arguments [x,y,width,height]
function p = bayes(img,color,varargin)
    for k = 1:nargin-2
        current = varargin{k};
        cov = zeros([3,3]);
        average = [0,0,0];
        for x = current(1):current(1)+current(3)
           for y = current(2):current(2)+current(4)
               average = average + color(img(y,x),:);
           end
        end
        for i = 1:3
           for j = 1:3
               for x = current(1):current(1)+current(3)
                   for y = current(2):current(2)+current(4)
                       cov(i,j) = cov(i,j) + (color(img(y,x),i)-average(i)) * (color(img(y,x),j)-average(j));
                   end
               end
               cov(i,j) = cov(i,j) / (current(3)*current(4));
           end
        end
        detcov = det(cov);
        invcov = inv(cov);
        p{k} = @(color) 1/((2*pi)^(3/2)*sqrt(detcov))*exp(-1/2 * (color-average) * invcov * transpose(color-average));
    end
end