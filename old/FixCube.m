% fix x,y,z,t cube to extrapolate SWE with elevation
function NewCube=FixCube(OldCube,X0,b_lapse)
%
% input
%   OldCube old SWE=f(x,y,z,t) cube
%   zvec vector of elevations corresponding to 3rd dimension of cube
%
% output
%   NewCube new SWE cube with SWE=f(z) filled in

N=size(OldCube);
% npts=100;
%reshape inputs
%rows=time, cols=image vector
workingcube=reshape(OldCube,N(1)*N(2),N(3))';
% slice into days
for n=1:size(workingcube,1);
    s=squeeze(workingcube(n,:))';
    t=isnan(s);
    if nnz(t) < length(s)-1 && nnz(t) > 0
        %Nearest neighbor SWE values
        F=scatteredInterpolant(double(X0(~t,:)),...
        s(~t),'linear','linear');
        vSWE=F(double(X0(t,:)));
        %Nearest neighbor elevaton values
%         F=scatteredInterpolant(double(X0(~t,:)),double(X0(~t,3)),...
%             'nearest','nearest');
%         vZ=F(double(X0(t,:)));
%         %elevation difference between NN and each pixel that needs
%         %extrapolated SWE
%         dZ=X0(t,3)-vZ;
        %extrapolated SWE as NN SWE + difference in elevation*slope coeff.
s(t)=vSWE;         
% s(t)=vSWE+b_lapse(2)*dZ;
    end
    workingcube(n,:)=s;
end

NewCube=workingcube;
NewCube(NewCube<0|isnan(NewCube))=0;