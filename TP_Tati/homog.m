function H=homog(pg,pd)
    % hartley normalization
    n = size(pg,2);
    uk = 1/n*sum(pg(1,:));
    vk = 1/n*sum(pg(2,:));
    for i=1:n
        a(i)=norm([pg(1,i)-uk pg(2,i)-vk]);
    end
    ak = sqrt(2) / mean(mean(a));
    Tg = [ak 0 -ak*uk;0 ak -ak*vk;0 0 1]
    pg = [pg; ones(1,n)];
    pg = Tg*pg;

    uk = mean(pd(1,:));
    vk = mean(pd(2,:));
    for i=1:n
        a(i)=norm([pd(1,i)-uk pd(2,i)-vk]);
    end
    ak = sqrt(2) / mean(mean(a));
    Td = [ak 0 -ak*uk;0 ak -ak*vk;0 0 1]
    pd = [pd; ones(1,n)];
    pd = Td*pd;
    % estimation of h
    D = [];
    for i=1:n
        ui = pg(1,i);
        vi = pg(2,i);
        uip = pd(1,i);
        vip = pd(2,i);
        D = [D;[ui vi 1 0 0 0 (-uip*ui) (-uip*vi) (-uip)];[0 0 0 ui vi 1 (-vip*ui) (-vip*vi) (-vip)]];
    end
    [V,M] = eig(D'*D);
    h = V(:,1);
    H = reshape(h,3,3)'
    H = inv(Td)*H*Tg;
end

% estimateFundamentalMatrix