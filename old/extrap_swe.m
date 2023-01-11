function eswe=extrap_swe(X0,xs,ys)
X=[x y Z(row,col)];
Y=SWEpts.XP;
d=sqrt((X(1)-Y(:,1)).^2+(X(2)-Y(:,2)).^2+(X(3)-Y(:,3)).^2);
[ds,i]=sort(d);

elevation=zeros(10,1);
swe=NaN(10,1);

for j=1:10;
    ind=SWEpts.SWE(:,2)==i(j) & SWEpts.SWE(:,3)==dateind;
    if any(ind)
    swe(j)=SWEpts.SWE(ind,1);
    elevation(j)=SWEpts.XP(i(j),3);
    end
end

b=regress(swe,[elevation ones(size(swe))]);
zdiff=Z(row,col)-elevation(1);
Y(row,col)=swe(1)+zdiff*b(1);