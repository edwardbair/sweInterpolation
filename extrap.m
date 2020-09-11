function Y=extrap(X0,xs,ys,N)
%extrapolate based on regression w/ nearest N points
Y=zeros(size(X0,1),1);
for i=1:length(X0);
    d=sqrt((X0(i,1)-xs(:,1)).^2+(X0(i,2)-xs(:,2)).^2+(X0(i,3)-xs(:,3)).^2);
    [~,idx]=sort(d);
    y=zeros(N,1);
    x=NaN(N,3);
    for j=1:N;
        y(j)=ys(idx(j));
        x(j,:)=xs(idx(j),:);
    end
%     x=[ones(length(x),1) x];
%     %regression based on 
%     b=x\y;
%     Y(i)=b(1)+b(2)*X0(i,1)+b(3)*X0(i,2)+b(4)*X0(i,3);
    x=[ones(length(x),1) x(:,3)];
    %regression based on elevation alone
    b=x\y;
    Y(i)=b(1)+b(2)*X0(i,3);
end