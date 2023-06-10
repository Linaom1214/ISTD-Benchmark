% This matlab code implements the infrared small target detection model
% based on partial sum of the tensor nuclear norm.
% 
% Reference:
% Zhang, L.; Peng, Z. Infrared Small Target Detection Based on Partial Sum 
% of the Tensor Nuclear Norm. Remote Sens. 2019, 11, 382.
%
% Written by Landan Zhang 
% 2019-2-24
clc;
clear;
close all;

addpath('functions/')
addpath('tools/')
saveDir = 'results/';
imgpath = 'images/';
imgDir = dir([imgpath '*.bmp']);

% patch parameters
patchSize = 40;
slideStep = 40;
lambdaL = 0.7;  %tuning

len = length(imgDir);
for i=1:len
    img = imread([imgpath imgDir(i).name]);
    figure,subplot(131)
    imshow(img),title('Original image')

    if ndims( img ) == 3
        img = rgb2gray( img );
    end
    img = double(img);

    %% constrcut patch tensor of original image
    tenD = gen_patch_ten(img, patchSize, slideStep);
    [n1,n2,n3] = size(tenD);  
    
    %% calculate prior weight map
    %      step 1: calculate two eigenvalues from structure tensor
    [lambda1, lambda2] = structure_tensor_lambda(img, 3);
    %      step 2: calculate corner strength function
    cornerStrength = (((lambda1.*lambda2)./(lambda1 + lambda2)));
    %      step 3: obtain final weight map
    maxValue = (max(lambda1,lambda2));
    priorWeight = mat2gray(cornerStrength .* maxValue);
    %      step 4: constrcut patch tensor of weight map
    tenW = gen_patch_ten(priorWeight, patchSize, slideStep);
    
    %% The proposed model
    lambda = lambdaL / sqrt(max(n1,n2)*n3); 
    [tenB,tenT] = trpca_pstnn(tenD,lambda,tenW); 
    
    %% recover the target and background image
    tarImg = res_patch_ten_mean(tenT, img, patchSize, slideStep);
    backImg = res_patch_ten_mean(tenB, img, patchSize, slideStep);

    maxv = max(max(double(img)));
    E = uint8( mat2gray(tarImg)*maxv );
    A = uint8( mat2gray(backImg)*maxv );
    subplot(132),imshow(E,[]),title('Target image')
    subplot(133),imshow(A,[]),title('Background image')

    % save the results
    imwrite(E, [saveDir 'target/' imgDir(i).name]);
    imwrite(A, [saveDir 'background/' imgDir(i).name]);
    
end