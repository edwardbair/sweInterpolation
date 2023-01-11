function RawSWE=SWEcube2(Csize,Ssize,Cc,z,Zs)
% get raw interpolated SWE cube from coarse cube & elevation grid
% input
%   Csize size of 1st 3 dimensions of 4D cube (but Cc is a sparse matrix)
%   Ssize size of full 3D space-time S cube (also a sparse matrix)
%   Cc  output of CoarseCube - 4D cube of x,y,z,t as a sparse matrix
%   z scaled elevations corresponding to 3rd dimension of Cc
%   Zs scaled elevation grid
%   Ssize size of cube of SCA values corresponding to Zs and dates
%
% output
%   RawSWE interpolated SWE without the SCA values

% make sure input grid and cube are same
NZ=size(Zs);
if ~isequal(NZ,Ssize(1:2))
    error('SWEcube: input grid Zs and cube S must have same spatial dimension')
end
% make sure Cc and Ssize have same number of days
if size(Cc,2)~=Ssize(3)
    error('SWEcube: number of days in coarse cube must match S cube')
end

% expand to the finer grid
RawSWE=zeros(Ssize);
for day=1:Ssize(3)
    % one day at a time
    SPlane=zeros(NZ(1),NZ(2),length(z));
    ccube=reshape(full(Cc(:,day)),Csize);
    for zlevel=1:length(z)
        SPlane(:,:,zlevel)=imresize(squeeze(ccube(:,:,zlevel)),...
            size(Zs),'bilinear');
    end
    t=isnan(SPlane) | SPlane < 0;
    SPlane(t)=0;
    RawSWE(:,:,day)=ZInterp(SPlane,z,Zs);
end
t=isnan(RawSWE)|RawSWE<0;
RawSWE(t)=0;
RawSWE=Sparsify3(RawSWE);