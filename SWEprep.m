function [SWE,P,C,XP,XC]=SWEprep(mstruct,R,D,Z,S,pflag,cflag,conn)
% get SWE data from pillows and courses, amalgamate into single array along
% with SCA data
% input
%   mstruct MATLAB mstruct variable to describe projection of Z & S
%   R referencing matrix for Z and S
%   D vector of input datevals in SCA cube S
%   Z elevation grid
%   S cube of SCA values with same R and dimension (size(Z),D)
%   pflag if true, get pillow data
%   cflag if true, get course data
%   conn, matlab db connection object
%
% output
%   SWE Nx4 matrix, column 1 is SWE, col 2 is index into the pillow and
%       course vector of coordinates, with negative indices indicating
%       courses, column 3 is index into the datevals
%       vector from the S cube, column 4 is SCA from the S cube
%   P vector of pillow CDEC codes
%   C vector of course CDEC codes
%   XP vector of x,y,z coordinates of pillows
%   XC vector of x,y,z coordinates of pillows


% make sure input grid and cube are same
NZ=size(Z);
NS=size(S);
ns=NS;
ns(3)=[];
if ~isequal(NZ,ns)
    error('input grid Z and cube S must have same spatial dimension')
end
if length(D)~=NS(3)
    error('3rd dimension of S cube must be same size as D vector')
end

% get the input pillow and/or course locations
[P,C,XP,XC]=getGridStations(mstruct,R,Z,conn);

% check to make sure we are asking for some data
if isempty(P)||isempty(pflag)
    pflag=false;
end
if isempty(C)||isempty(cflag)
    cflag=false;
end
if ~(pflag||cflag)
    error('either pflag or cflag must be true (or both)')
end

% find row,col image coordinates associated with the SWE measurements
[rowp,colp]=map2pix(R,XP(:,1),XP(:,2));
rowp=round(rowp);
colp=round(colp);
[rowc,colc]=map2pix(R,XC(:,1),XC(:,2));
rowc=round(rowc);
colc=round(colc);

% get the SWE data
% 1/2 day buffer at both ends
% and fill in SCA values from S cube
d=floor(D);
pswe=[];
cswe=[];
if pflag
    [pswe,pillowdates]=getSWE(P,'pillow',...
        datestr(min(D)-.5),datestr(max(D)+.5),conn);
    if ~isempty(pswe)
        pd=floor(pillowdates);
        sca=zeros(size(pswe,1),1);
        for k=1:length(pillowdates)
%             m=find(d==pd(k)); %find closest date instead of exact
            [~,m]=min(abs(d-pd(k)));
            t=pswe(:,3)==k;
            pswe(t,3)=m;
            s=squeeze(S(:,:,m));
            sr=reshape(s,numel(s),1);
            ix=sub2ind(size(s),rowp(pswe(t,2)),colp(pswe(t,2)));
            sca(t)=sr(ix);
        end
        pswe=cat(2,pswe,sca);
    end
end
if cflag
    [cswe,coursedates]=getSWE(C,'course',...
        datestr(min(D)-.5),datestr(max(D)+.5),conn);
    if ~isempty(cswe)
        cswe(:,2)=-cswe(:,2);
        cd=floor(coursedates);
        sca=zeros(size(cswe,1),1);
        for k=1:length(coursedates)
%             m=find(d==cd(k));
            [~,m]=min(abs(d-cd(k)));
            t=cswe(:,3)==k;
            cswe(t,3)=m;
            s=squeeze(S(:,:,m));
            sr=reshape(s,numel(s),1);
            ix=sub2ind(size(s),rowc(-cswe(t,2)),colc(-cswe(t,2)));
            sca(t)=sr(ix);
        end
        cswe=cat(2,cswe,sca);
    end
end
SWE=cat(1,pswe,cswe);
end