x = double(imread('images/boats.png'));
% imagesc(x);
% colormap(gray);
% axis image;
Ps = mean(mean(x.*x));
sigma = sqrt(Ps/(10^(10/20)));
y=x+sigma*randn(size(x));
figure(1);
subplot(1,2,1);
imagesc(y);
axis image;
colormap(gray);
subplot(1,2,2);
histogram(y);
c = fwt2(y,'db4',4);
figure(2);
subplot(1,2,1);
imagesc(dynlimit(20*log10(abs(c)),70));
axis('image'); colormap(gray);
subplot(1,2,2);
histogram(c);
T = sqrt(2) * Ps / sqrt(mean(mean(y.*y)));
for k = 1:size(c,1)
  for l = 1:size(c,2)
    if c(k,l) < -T
      soft(k,l) = c(k,l)+T;
    elseif c(k,l) > T
      soft(k,l) = c(k,l)-T;
    else
      soft(k,l) = 0;
    end
  end
end
for k = 1:size(c,1)
  for l = 1:size(c,2)
    if c(k,l) < -T
      hard(k,l) = c(k,l);
    elseif c(k,l) > T
      hard(k,l) = c(k,l);
    else
      hard(k,l) = 0;
    end
  end
end
figure(3);
subplot(3,2,1);
soft_real = ifwt2(soft,'db4',4);
imagesc(soft_real);
colormap(gray);
subplot(3,2,2);
histogram(soft_real);
subplot(3,2,3);
hard_real = ifwt2(hard,'db4',4);
imagesc(hard_real);
colormap(gray);
subplot(3,2,4);
histogram(hard_real);
subplot(3,2,5);
imagesc(x);
colormap(gray);
subplot(3,2,6);
histogram(x);