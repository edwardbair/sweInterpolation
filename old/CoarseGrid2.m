function [v0,z0]=CoarseGrid2(imsize,X,Xc,Y,X0)
% % interpolation to 4D grid
% input
%   imsize size of first 3 dimensions of v0
%   X x,y,z,t coordinates where Y is known
%   Xc x,y,z coordinates of convex hull where Y is zero
%   X0 [x0 y0 z0] grid
%
% output
%   v0 4D grid imsize x max value of X(:,4)
%   z0 scaled elevation vector corresponding to 3rd dimension of v0

N=max(X(:,4));
v0=zeros([imsize N]);
parfor k=1:N
    fprintf('interpolating day %i\n',k)
    d=X(:,4)==k;
    ys=Y(d);
    xx=X(d,1:3);
    xx=cat(1,xx,Xc);
    ys=cat(1,ys,zeros(size(Xc,1),1));
%   v=griddatan(xx,ys,X0);
    %3-d (x,y,z) interpolation for each timestep k
    F=scatteredInterpolant(xx,ys);
    v=F(double(X0));
    v=reshape(v,imsize);
    v0(:,:,k)=v;
%     v0(:,:,:,k)=reshape(v,imsize);
    fprintf('done interpolating day %i\n',k);
end
% z0=unique(X0(:,3));
v0=FixCube2(v0,X0(:,3));
% v0=sparse(reshape(v0,prod(imsize),N));