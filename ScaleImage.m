function X0=ScaleImage(R,N,Z,a,b)
% scale the image coordinates and generate the output coordinates
% input
%   R referencing matrix
%   N 2D size of input grid
%   Z elevation grid
%   a,b scaling parameters for x,y,z coordinates
%
% output
%   X0 output coordinates x,y,z

[x,y] = pixcenters(R, N,'makegrid');

% scale them
xi=b(1)*(x-a(1));
yi=b(2)*(y-a(2));

% elevations
zi=b(3)*(Z-a(3));
% x y z column vectors in X0
X0=[xi(:),yi(:),zi(:)];