% interpolates from coarse 3D grid to finer 2D grid at which elevation at each
% grid cell is known
function S=ZInterp(Sfull,zvec,Zs)
% input
%   Sfull coarse 3D grid with values of S in each voxel
%   zvec elevation vector of 3rd dimension of 3D grid
%   Zs scaled elevation matrix for interpolated grid, at which value of
%       S=f(x,y,Z)is wanted
%
% output
%   S grid of same size as Zs with interpolated values of S

if size(Sfull,3)~=length(zvec)
    error('length of z vector must be same as 3rd dimension of Sfull')
end
sf=reshape(Sfull,prod([size(Sfull,1) size(Sfull,2)]),size(Sfull,3));
zf=reshape(Zs,numel(Zs),1);
t=sum(sf,2) > 0 & zf > 0;
S=zeros(size(zf));
positiveK=find(t);
for m=1:length(positiveK);
    k=positiveK(m);
    n=find(zvec < zf(k),1,'last');
    if n==length(zvec)
        S(k)=sf(k,end);
    else
%         S(k)=interp1(zvec(n:n+1),sf(k,n:n+1),zf(k),'linear');
        S(k)=sf(k,n)+(sf(k,n+1)-sf(k,n))*...
            (zf(k)-zvec(n))/(zvec(n+1)-zvec(n));
    end
end
S=reshape(S,size(Zs));