% change S cube into sparse matrix or vector depending on dimensions,
% converting NaNs to zero
function Sp=Sparsify3(S)
N=size(S);
S(isnan(S))=0;
if length(N)==2 % just one day
    Sp=sparse(reshape(double(S),N(1)*N(2),1));
elseif length(N)==3
    Sp=sparse(reshape(double(S),N(1)*N(2),N(3)));
else
    error('S cube has wrong # of dimensions')
end