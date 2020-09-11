% parameters to scale input values to prevent matrix singularity
function [a,b]=ScaleParms(X)
%
% input
%   X matrix
%
% output
%   a,b scaling parameter so Xscale=b*(X-a)
%       (to invert, X=(a*b+Xscale)/b)
b=1./(max(X)-min(X))';
a=min(X)';