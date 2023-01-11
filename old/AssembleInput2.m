% arrange input for interpolation - x,y,z scaled to prevent singularity
% function [Y,X,Xc]=AssembleInput2(SWE,XP,XC,Xconvx)

function [Y,X,Xc,a,b]=AssembleInput2(SWE,XP,XC,Xconvx)

% input
%   SWE snow water equivalent from GetSWE - Nx3 matrix,
%       column 1 is snow water equivalent, col 2 is index
%       the location vector (negative for courses),
%       col 3 is index into the datevals vector
%   XP location vector for pillows
%   XC location vector for courses
%   Xconvx location vector of convex hull
%
% output
%   Y column vector of SWE values
%   X Nx4 matrix of locations and dates - cols 1-3 are x,y,z, col 4 is
%       index to datevals vector, col 5 is SCA
%       cols 1-3 are scaled from 0-1
%   Xc Nx3 matrix of locations of convex hull, scaled from 0-1
%   a,b scaling parameter, such that Xscale=b*(X-a)
%       [to invert, X=(a*b+Xscale)/b) ]

Y=SWE(:,1);
X=zeros(length(Y),3);
X(:,4)=SWE(:,3); % datevals index in col 4
X(:,5)=SWE(:,4); % SCA in col 5

pts=SWE(:,2);
pp=unique(pts(pts>0));
pn=unique(pts(pts<0));
for k=1:length(pp)
    t=pts==pp(k);
    for c=1:3
        X(t,c)=XP(pp(k),c);
    end
end
for k=1:length(pn)
    t=pts==pn(k);
    for c=1:3
        X(t,c)=XC(-pn(k),c);
    end
end

% prevent duplicates
[X,ui]=unique(X,'rows');
Y=Y(ui,:);

% scale cols 1-3 of X and all of Xconvx from 0-1
[a,b]=ScaleParms(cat(1,X(:,1:3),Xconvx));
Xc=zeros(size(Xconvx));
for k=1:3
    X(:,k)=b(k)*(X(:,k)-a(k));
    Xc(:,k)=b(k)*(Xconvx(:,k)-a(k));
end
end