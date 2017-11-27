if not(exist('f'))
    f = rescale( crop(load_image('barb'),256) );
end
n0 = size(f,1);

clf;
imageplot(clamp(f));
%%

w = 10;
n = w*w;
p = 2*n;
m = 20*p;
k = 4;
q = 3*m;
x = floor( rand(1,1,q)*(n0-w) )+1;
y = floor( rand(1,1,q)*(n0-w) )+1;

[dY,dX] = meshgrid(0:w-1,0:w-1);
Xp = repmat(dX,[1 1 q]) + repmat(x, [w w 1]);
Yp = repmat(dY,[1 1 q]) + repmat(y, [w w 1]);
Y = f(Xp+(Yp-1)*n0);
Y = reshape(Y, [n q]);

Y = Y - repmat( mean(Y), [n 1] );

[tmp,I] = sort(sum(Y.^2), 'descend');
Y = Y(:,I(1:m));

ProjC = @(D)D ./ repmat( sqrt(sum(D.^2)), [w^2, 1] );
sel = randperm(m); sel = sel(1:p);
D0 = ProjC( Y(:,sel) );
D = D0;

clf;
plot_dictionnary(D, [], [8 12]);
old_D = D;

select = @(A,k)repmat(A(k,:), [size(A,1) 1]);
ProjX = @(X,k)X .* (abs(X) >= select(sort(abs(X), 'descend'),k));

niter_learning = 10;
niter_dico = 50;
niter_coef = 100;
E0 = [];
X = zeros(p,m);
D = D0;
for iter = 1:niter_learning
    % --- coefficient update ----
    E = [];
    gamma = 1.6/norm(D)^2;
    for i=1:niter
        R = D*X - Y;
        E(end+1,:) = sum(R.^2);
        X = ProjX(X - gamma * D'*R, k);
    end
    E0(end+1) = norm(Y-D*X, 'fro')^2;
    % --- dictionary update ----
    E = [];
    tau = 1/norm(X*X');
    for i=1:niter_dico
        R = D*X - Y;
        E(end+1) = sum(R(:).^2);
        D = ProjC( D - tau * (D*X - Y)*X' );
    end
    E0(end+1) = norm(Y-D*X, 'fro')^2;
end
clf; hold on;
plot(1:2*niter_learning, E0);
plot(1:2:2*niter_learning, E0(1:2:2*niter_learning), '*');
plot(2:2:2*niter_learning, E0(2:2:2*niter_learning), 'o');
axis tight;
legend('|Y-DX|^2', 'After coefficient update', 'After dictionary update');
%%
clf;
subplot(1,2,1);
plot_dictionnary(old_D, [], [8 12]);
%%
subplot(1,2,2);
plot_dictionnary(D,X, [8 12]);
%%
imageplot(clamp(D*X));