load('tennis.mat');
I_rect = rectim(I,uv,XY);
imagesc(I_rect);
colormap(gray);