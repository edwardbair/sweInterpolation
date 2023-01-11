function Xconvx=ConvHullPts2(mstruct,R,Z,Sp,SWEpts)
% x,y,z coordinates of the convext hull of the SCA and pt SWE
% input
%   mstruct,  projection structure for Z
%   R, referencing matrix for Z
%   Z, elevation grid
%   SCA cube of size (numel(Z),length(D))
%   SWEpts structure (output of SimplifySWE)
%
% output
%   X x,y,z,d coordinates of the convex hull of the max SCA and SWE

% x,y of max SCA for each pixel over time period
Sm=max(Sp,[],1)';
t=Sm>0;
[i,j]=ind2sub(size(Z),find(t));
[x,y]=pix2map(R,i,j);

% add the coordinates of the pillows for SWE>0
t=SWEpts.SWE(:,1)>0; % all pillows and course with SWE>0
pts=unique(SWEpts.SWE(t,2));
pp=pts(pts>0); % only the pillows
if ~isempty(pp)
    % eliminate XP coordinates that do not have SWE>0
    if length(pp)<length(SWEpts.XP)
        XP=SWEpts.XP(pp,:);
    else
        XP=SWEpts.XP;
    end
else
    XP=[];
end
pn=pts(pts<0); % only the courses
if ~isempty(pn)
    % eliminate XC coordinates that do not have SWE>0
    if length(pn)<length(SWEpts.XC)
        pn=-pn;
        XC=SWEpts.XC(pn,:);
    else
        XC=SWEpts.XC;
    end
else
    XC=[];
end
% concatenate the coordinates
if ~isempty(XP) || ~isempty(XC)
    XP=unique(cat(1,XP,XC),'rows');
    x=cat(1,x,XP(:,1));
    y=cat(1,y,XP(:,2));
end
X=unique([x y],'rows');
x=X(:,1);
y=X(:,2);
Kp=convhull(x,y);
x=x(Kp);
y=y(Kp);
%convert to cw for interior polygon
[x,y]=poly2cw(x,y);

% convert to lat,lon to specify a buffer of 3X pixel size
dist=max(abs([R(1,2) R(2,1)]))*3;
[lat,lon]=projinv(mstruct,x,y);
dist=dist/100000;
%reduce density of lat lon data to 0.25 deg for faster buffering
[lat,lon]=reducem(lat,lon,0.25);
% whole polygon including the original
[latb,lonb]=bufferm(lat,lon,dist,'outPlusInterior');
% convert the buffered lat,lon back to x,y
[xb,yb]=projfwd(mstruct,latb,lonb);
% find the i,j coordinates
[i,j]=map2pix(R,xb,yb);
i=round(i);
j=round(j);
i(i<1)=1;
i(i>size(Z,1))=size(Z,1);
j(j<1)=1;
j(j>size(Z,2))=size(Z,2);
% add the z coordinate
zb=zeros(size(xb));
for k=1:length(zb)
    zb(k)=Z(i(k),j(k));
end
Xconvx=[xb yb zb];
Xconvx(end,:)=[]; % end pts are duplicate