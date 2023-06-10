function res=run_PSTNN(img)
    addpath('functions/')
    addpath('tools/')
    saveDir = 'results/';
    imgpath = 'images/';
    imgDir = dir([imgpath '*.bmp']);

    % patch parameters
    patchSize = 40;
    slideStep = 40;
    lambdaL = 0.7;  %tuning
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
    [~,tenT] = trpca_pstnn(tenD,lambda,tenW); 
    
    %% recover the target and background image
    res = res_patch_ten_mean(tenT, img, patchSize, slideStep);
end