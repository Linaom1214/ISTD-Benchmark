clearvars
% close all
% clc
img_orig=imread('img_012.bmp');
%img_orig=rgb2gray(img_orig);
img=double(img_orig);
figure;imshow(img,[]);
img=medfilt2(img,[3,3]);
title('original image');

gauss_krl=[1,2,1;2,4,2;1,2,1]./16;
I_gauss=imfilter(img,gauss_krl,'replicate');
%figure;imshow(I_gauss,[]);
%title('Gaussian smoothed image');

scs=[5, 7 , 9 , 11];
itter=length(scs);


K=9;
m0=zeros(size(img,1),size(img,2),K);
m1=zeros(size(img,1),size(img,2),K);
m2=zeros(size(img,1),size(img,2),K);
m3=zeros(size(img,1),size(img,2),K);
m4=zeros(size(img,1),size(img,2),K);
m5=zeros(size(img,1),size(img,2),K);
m6=zeros(size(img,1),size(img,2),K);
m7=zeros(size(img,1),size(img,2),K);
m8=zeros(size(img,1),size(img,2),K);

temp1=zeros(size(img,1),size(img,2),8);
temp2=zeros(size(img,1),size(img,2),8);
Fout=zeros(size(img,1),size(img,2),itter);

for i=1:itter
    [mask1,mask2,mask3,mask4,mask5,mask6,mask7,mask8] = create_mask(scs(i));

    for j=1:K
        m0(:,:,j)=ordfilt2(img,scs(i)^2+1-j, ones(scs(i)));
        mean0=imfilter(img,ones(scs(i)),'replicate')/(scs(i)^2);
        m1(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask1);
        mean1=imfilter(img,mask1,'replicate')/(scs(i)^2);
        m2(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask2);
        mean2=imfilter(img,mask2,'replicate')/(scs(i)^2);
        m3(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask3); 
        mean3=imfilter(img,mask3,'replicate')/(scs(i)^2);
        m4(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask4); 
        mean4=imfilter(img,mask4,'replicate')/(scs(i)^2);
        m5(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask5); 
        mean5=imfilter(img,mask5,'replicate')/(scs(i)^2);
        m6(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask6); 
        mean6=imfilter(img,mask6,'replicate')/(scs(i)^2);
        m7(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask7); 
        mean7=imfilter(img,mask7,'replicate')/(scs(i)^2);
        m8(:,:,j)=ordfilt2(img,scs(i)^2+1-j, mask8); 
        mean8=imfilter(img,mask8,'replicate')/(scs(i)^2);
    end
    M0=mean(m0,3);
    M1=mean(m1,3);
    M2=mean(m2,3);
    M3=mean(m3,3);
    M4=mean(m4,3);
    M5=mean(m5,3);
    M6=mean(m6,3);
    M7=mean(m7,3);
    M8=mean(m8,3);
    
    temp1(:,:,1)=M1;
    temp1(:,:,2)=M2;
    temp1(:,:,3)=M3;
    temp1(:,:,4)=M4;
    temp1(:,:,5)=M5;
    temp1(:,:,6)=M6;
    temp1(:,:,7)=M7;
    temp1(:,:,8)=M8;
    
    BE=max(temp1,[],3);
    
    SLCM=((I_gauss.^2)./BE)-I_gauss;
    tt=SLCM>0;
    SLCM=double(tt).*SLCM;
    
    %figure;imshow(SLCM,[]);
    %title('SLCM');
    
    IRIL0=M0-mean0;
    IRIL1=M1-mean1;
    IRIL2=M2-mean2;
    IRIL3=M3-mean3;
    IRIL4=M4-mean4;
    IRIL5=M5-mean5;
    IRIL6=M6-mean6;
    IRIL7=M7-mean7;
    IRIL8=M8-mean8;
    
    
    temp2(:,:,1)=IRIL1;
    temp2(:,:,2)=IRIL2;
    temp2(:,:,3)=IRIL3;
    temp2(:,:,4)=IRIL4;
    temp2(:,:,5)=IRIL5;
    temp2(:,:,6)=IRIL6;
    temp2(:,:,7)=IRIL7;
    temp2(:,:,8)=IRIL8;
    
    
    IRIL_max=max(temp2,[],3);
    
    WD=IRIL0-IRIL_max;
    tt=WD>0;
    WD=double(tt).*WD;
    
    WB=std(temp2,0,3);
    xi=5;
    tt=WB>xi;
    ttc=~tt;
    offset=5*double(ttc);
    WB=double(tt).*WB+offset;
    
    W=(IRIL0.*WD)./(WB);
    %figure;imshow(W,[]);
    %title('W');
    
    WSLCM_Result=W.*SLCM;
    %figure;imshow(WSLCM,[]);
    %title('WSLCM');
    
    Fout(:,:,i)=WSLCM_Result;
    
end

MS_WSLCM=max(Fout,[],3);
figure;imshow(MS_WSLCM,[]);
title('Multi-scale WSLCM');



