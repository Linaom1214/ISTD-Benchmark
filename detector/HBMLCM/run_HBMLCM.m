% High-Boost-Based Multiscale Local Contrast Measure for Infrared Small Target Detection
function re = run_HBMLCM(img)
img = double(img);
op = fspecial('average', 9); % improved high boost filter
Im = imfilter(double(img), op, 'symmetric');
Ihp = img - Im;
Ihp(Ihp<0) = 0;
ihbf = img.*Ihp;
%% scae 3
d3 = subfunc(ihbf, 3);
%% scae 5
d5 = subfunc(ihbf, 5);
%% scae 7
d7 = subfunc(ihbf, 7);
%% scae 9
d9 = subfunc(ihbf, 9);
%%
out = cat(3, d3, d5, d7, d9);
dmin = min(abs(out), [], 3);
dmax = max(abs(out), [], 3);
re = (dmax - dmin).^2;
% re = mapminmax(re, 0, 1);

% [maxval, ~] = max(re(:));
% re(re<maxval) = 0;
% [row, col] = ind2sub(size(re), ind);
end
function d = subfunc(ihbf, len)
top = ones(len)/(len*len) ;
r = floor(len/2);
bop = ones(15); % the size of the external window is fixed and it is set to 15 �� 15 pixels in experiments
bop(8-r:8+r, 8-r:8+r) = 0;
bop = bop/sum(bop(:));
mt = imfilter(double(ihbf), top, 'symmetric');
mb =  imfilter(double(ihbf), bop, 'symmetric');
d = mt - mb;
end

