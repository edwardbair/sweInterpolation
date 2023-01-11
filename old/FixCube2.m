% fix x,y,z,t cube to extrapolate SWE with elevation
function NewCube=FixCube2(OldCube,zvec)
%
% input
%   OldCube old SWE=f(x,y,z,t) cube
%   zvec vector of elevations corresponding to 3rd dimension of cube
%
% output
%   NewCube new SWE cube with SWE=f(z) filled in

N=size(OldCube);
% nz=length(zvec);
% if nz~=N(3)
%     error('length of elevation vector must be same as 3rd dimension of cube')
% end
% fill in the cube, extrapolating at lower elevations and using
% last known value at higher elevations
% workingcube=zeros(N);

%reshape inputs
%transpose is req'd because reshape operates on columns
%rows=time, cols=image vector
workingcube=reshape(OldCube,N(1)*N(2),N(3))';

parfor n=1:size(workingcube,1);
    s=squeeze(workingcube(n,:));
    t=isnan(s);
    if nnz(t) < length(s)-1 && nnz(t) > 0
        m=find(~t,1,'first');
        tz=zvec<zvec(m);
        if nnz(tz)
            s(tz)=interp1(zvec(~t),s(~t),zvec(tz),'linear','extrap');
            toomuch=tz&s>s(m);
            s(toomuch)=s(m);
            t=t&~tz;
        end
        s(t)=interp1(zvec(~t),s(~t),zvec(t),'pchip',max(s(~t&~tz)));
        workingcube(n,:)=s;
    end
end

NewCube=workingcube;
NewCube(NewCube<0|isnan(NewCube))=0;