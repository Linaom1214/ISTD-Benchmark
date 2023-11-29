% This script removes single pixels
% salt & pepper noise. It is also 
% able to remove horizontaly joint
% noisy pixels

clearvars
close all
clc


img=imread('test.bmp');
img1=imfilter(img,[0.5;0;0.5],'replicate');
img2=abs(img1-img);
Thresh_n=50;
img2=uint8(img2-Thresh_n);

mask=logical(img2);
mask2=~mask;
img3=double(mask2).*img;

img4=double(mask).*img1;

out=img3+img4;
figure;imshow(out,[])
