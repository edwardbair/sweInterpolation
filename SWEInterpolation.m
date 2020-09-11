function [RawSWE,SCAswe,SWEpts]=SWEInterpolation(mstruct,R,D,Z,S,conn,...
    smooth_filt,extrap,h5flag,varargin)
% creates SWE pillow/course interpolation
% input
%   mstruct projection structure for lat-lon to x-y conversion
%   R referencing matrix
%   D datevals vector (MATLAB date numbers)
%   Z elevation grid
%   S SCA time-space grid corresponding to Z
%   conn - matlab database connection object
%   smooth_filt, smooth resulting cubes
%   extrap, 'nearest' or 'regression', i.e. nearest neighbor or regression
%   based on elevation
%   h5flag - true/false, write out an h5,
%   if true then supply h5 filename as last argument
% output
%   RawSWE - interpolated SWE
%   SCAswe - interpolated SWE*SCA
%   SWEpts - output from SimplifySWE
% originally created by Jeff Dozier, rewritten by Ned Bair,
% 8/11/15,10/14/15,11/2/18

if h5flag
    if isempty(varargin{1});
        error('no h5 filename given');
    else
        h5name=varargin{1};
    end
end

% parpool_check(12);
% get the surface data, both courses & pillows
pflag=true;
cflag=true;

tic;
[SWE,P,C,XP,XC]=SWEprep(mstruct,R,D,Z,S,pflag,cflag,conn);
SWEpts=SimplifySWE(SWE,P,C,XP,XC);
disp('SWE data extracted from database');
toc;

%convert SCA cube to width*length X D for parallel processing
S=reshape(S,size(S,1)*size(S,2),size(S,3))';

tic
% x,y,z on the convex hull of the SCA and SWE
Xconvx=ConvHullPts(mstruct,R,Z,S,SWEpts);
disp('convex hull created');
% input ready to interpolate
[Y,X,Xc,a,b]=AssembleInput(SWE,XP,XC,Xconvx);
toc

disp('scaling image');tic;
% coordinates of interpolating grid
X0=ScaleImage(R,size(Z),Z,a,b);
disp('image scaled');toc;
tic
% Interpolation
disp('interpolating');
RawSWE=Interp4(size(Z),X,Xc,Y,X0,extrap);
disp('done interpolating')
toc;
S=reshape(S',[size(Z) length(D)]);

%if pillow obs end early, assume zeros for remaining days
if size(RawSWE,3) < size(D,1);
    m=size(D,1)-size(RawSWE,3);
    RawSWE=cat(3,RawSWE,zeros([size(Z) m]));
end

if smooth_filt
    tic;
    RawSWE=reshape(RawSWE,[size(Z,1)*size(Z,2) length(D)])';
    filt_len=5; % 5 day filter length
    disp('smoothing');
    parfor i=1:size(RawSWE,1)
        RawSWE(i,:)=medfilt1(double(squeeze(RawSWE(i,:))),filt_len);
        S(i,:)=medfilt1(double(squeeze(S(i,:))),filt_len);
    end
    RawSWE=reshape(RawSWE',[size(Z) length(D)]);
    toc
    disp('smoothed cubes');
end

SCAswe=RawSWE.*S;

if h5flag
    if exist(h5name,'file')~=0;
        delete(h5name);
    end
    location='/Grid';
    h5create(h5name,[location,'/','RawSWE'],size(RawSWE),'ChunkSize',...
        [size(RawSWE,1) size(RawSWE,2) 1],'Deflate',9,'DataType','uint16');
    h5create(h5name,[location,'/','SCAswe'],size(SCAswe),'ChunkSize',...
        [size(RawSWE,1) size(RawSWE,2) 1],'Deflate',9,'DataType','uint16');
    h5write(h5name,[location,'/','RawSWE'],uint16(RawSWE));
    h5write(h5name,[location,'/','SCAswe'],uint16(SCAswe));
    h5writeProjection(h5name,location,mstruct);
    h5writeatt(h5name,'/','MATLABdates',D);
    h5writeatt(h5name,'/Grid','ReferencingMatrix',R);
end