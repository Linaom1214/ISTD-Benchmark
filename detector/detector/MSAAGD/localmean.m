function mean=localmean(f,nhood)
if nargin==1
    nhood=ones(3)/9;
else
    nhood=nhood/(sum(nhood(:)));
end
mean=imfilter(f,nhood,'replicate');
% mean=imfilter(f,nhood,'replicate');