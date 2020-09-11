function v0=Interp4(imsize,X,Xc,Y,X0,extrap)
% Interpolation
% input
%   imsize size of first 3 dimensions of v0
%   X x,y,z,t coordinates where Y is known
%   Xc x,y,z coordinates of convex hull where Y is zero
%   X0 [x0 y0 z0] grid
%   extrap, 'nearest' or 'regression', i.e. nearest neighbor or regression
%   based on elevation 
% output
%   v0 4D grid imsize x max value of X(:,4)
if strcmp(extrap,'regression');
    method='none';
elseif strcmp(extrap,'nearest');
    method='nearest';
end
N=max(X(:,4));
v0=zeros([imsize N]);
X0=double(X0);
parfor k=1:N
    d=X(:,4)==k;
    ys=Y(d);
    xx=X(d,1:3);
    xx=cat(1,xx,Xc);
    ys=cat(1,ys,zeros(size(Xc,1),1));
    %eliminate duplicates
    [~,ia]=unique(xx,'rows');
    xx=xx(ia,:);
    ys=ys(ia);
    %3-d (x,y,z) interpolation for each timestep k
    F=scatteredInterpolant(xx,ys,'linear',method);
    v=zeros(length(X0),1);
    shp=alphaShape(Xc(:,1),Xc(:,2),Inf);
    in=inShape(shp,X0(:,1),X0(:,2));
    v(in)=F(X0(in,:));
    if strcmp(extrap,'regression');
        t = isnan(v) & in;
        Yextrap = extrap(X0(t,:),X(d,1:3),Y(d),20);
        v(t) = Yextrap;
    end
    %fix negative values
    v(v<0) = 0;
    v=reshape(v,imsize);
    v0(:,:,k)=v;
    fprintf('done interpolating day %i\n',k);
end