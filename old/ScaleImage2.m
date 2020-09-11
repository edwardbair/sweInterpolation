function X0=ScaleImage2(R,N,Z,a,b)
% function [xplot,yplot,X0,imsize]=ScaleImage2(R,N,Zmax,Zmin,a,b)
% scale the image coordinates and generate the output coordinates
% input
%   R referencing matrix
%   N 2D size of input grid
%   Zmax maximum elevation in grid
%   Zmin minimum elevation that has snow
%   a,b scaling parameters for x,y,z coordinates
%
% output
%   x,y scaled coordinates of input grid
%   X0 output coordinates (4D)
%   imsize size of the output 4D array

% maxsize=[128 128 48]; % max # points along y,x,Z coordinates
% Zmax=double(Zmax);
% Zmin=double(Zmin);

% x,y coordinates of rows and columns in original grid
% [x,~]=pix2map(R,ones(N(2),1),(1:N(2))');
% [~,y]=pix2map(R,(1:N(1))',ones(N(1),1));

[x,y] = pixcenters(R, N,'makegrid');

% scale them
% xplot=[x(1) x(end)];
% yplot=[y(1) y(end)];
x=b(1)*(x-a(1));
y=b(2)*(y-a(2));

% x,y coordinates of output grid
% if max(N)<=max(maxsize(1:2))
    xi=x;
    yi=y;
% else
%     ny=maxsize(1);
%     nx=maxsize(2);
%     if length(x)>length(y)
%         ny=ceil(maxsize(1)*length(y)/length(x));
%     elseif length(y)>length(x)
%         nx=ceil(maxsize(2)*length(x)/length(y));
%     end
%     xi=linspace(x(1),x(end),nx);
%     yi=linspace(y(1),y(end),ny);
% end

% elevations
% zi=Z;
zi=b(3)*(Z-a(3));
% zi=linspace(b(3)*(Zmin-a(3)),b(3)*(Zmax-a(3)),maxsize(3));

% everybody is a column vector
% if ~(isvector(xi) && isvector(yi) && isvector(zi))
%     error('one of the output coordinates is not a vector')
% end
% if size(xi,1)<size(xi,2)
%     xi=xi';
% end
% if size(yi,1)<size(yi,2)
%     yi=yi';
% end
% if size(zi,1)<size(zi,2)
%     zi=zi';
% end

% grid the coordinates
% [y0,x0,z0]=ndgrid(yi,xi,zi);
% X0=[x0(:) y0(:) z0(:)];
X0=[xi(:),yi(:),zi(:)];