function  re  = run_MSPCM( img )
% this function computes multiscale patch-based contrast measure (MPCM)
% the output image is acheieved using max selection through third dimension

%% inputs:
% img: the input image

%% output
% out: output filtered image
%%
[row,col]=size(img);
mask3=ones(3);
mask5=ones(5);
mask7=ones(7);
mask9=ones(9);

l3=localmean(img,mask3);
l5=localmean(img,mask5);
l7=localmean(img,mask7);
l9=localmean(img,mask9);

m31=zeros(9);
m32=zeros(9);
m33=zeros(9);
m34=zeros(9);
m35=zeros(9);
m36=zeros(9);
m37=zeros(9);
m38=zeros(9);
m31(1:3,1:3)=1;
m32(1:3,4:6)=1;
m33(1:3,7:9)=1;
m34(4:6,7:9)=1;
m35(7:9,7:9)=1;
m36(7:9,4:6)=1;
m37(7:9,1:3)=1;
m38(4:6,1:3)=1;


LCM3=zeros(row,col,8);
LCM3(:,:,1)=localmean(img,m31);
LCM3(:,:,2)=localmean(img,m32);
LCM3(:,:,3)=localmean(img,m33);
LCM3(:,:,4)=localmean(img,m34);
LCM3(:,:,5)=localmean(img,m35);
LCM3(:,:,6)=localmean(img,m36);
LCM3(:,:,7)=localmean(img,m37);
LCM3(:,:,8)=localmean(img,m38);

F31=l3-reshape(LCM3(:,:,1),row,col);
F32=l3-reshape(LCM3(:,:,2),row,col);
F33=l3-reshape(LCM3(:,:,3),row,col);
F34=l3-reshape(LCM3(:,:,4),row,col);
F35=l3-reshape(LCM3(:,:,5),row,col);
F36=l3-reshape(LCM3(:,:,6),row,col);
F37=l3-reshape(LCM3(:,:,7),row,col);
F38=l3-reshape(LCM3(:,:,8),row,col);

temp3=zeros(row,col,4);
temp3(:,:,1)=F31.*F35;
temp3(:,:,2)=F32.*F36;
temp3(:,:,3)=F33.*F37;
temp3(:,:,4)=F34.*F38;


out3=min(temp3,[],3);




m51=zeros(15);
m52=zeros(15);
m53=zeros(15);
m54=zeros(15);
m55=zeros(15);
m56=zeros(15);
m57=zeros(15);
m58=zeros(15);
m51(1:5,1:5)=1;
m52(1:5,6:10)=1;
m53(1:5,11:15)=1;
m54(6:10,11:15)=1;
m55(11:15,11:15)=1;
m56(11:15,6:10)=1;
m57(11:15,1:5)=1;
m58(6:10,1:5)=1;


LCM5=zeros(row,col,8);
LCM5(:,:,1)=localmean(img,m51);
LCM5(:,:,2)=localmean(img,m52);
LCM5(:,:,3)=localmean(img,m53);
LCM5(:,:,4)=localmean(img,m54);
LCM5(:,:,5)=localmean(img,m55);
LCM5(:,:,6)=localmean(img,m56);
LCM5(:,:,7)=localmean(img,m57);
LCM5(:,:,8)=localmean(img,m58);


F51=l5-reshape(LCM5(:,:,1),row,col);
F52=l5-reshape(LCM5(:,:,2),row,col);
F53=l5-reshape(LCM5(:,:,3),row,col);
F54=l5-reshape(LCM5(:,:,4),row,col);
F55=l5-reshape(LCM5(:,:,5),row,col);
F56=l5-reshape(LCM5(:,:,6),row,col);
F57=l5-reshape(LCM5(:,:,7),row,col);
F58=l5-reshape(LCM5(:,:,8),row,col);

temp5=zeros(row,col,4);
temp5(:,:,1)=F51.*F55;
temp5(:,:,2)=F52.*F56;
temp5(:,:,3)=F53.*F57;
temp5(:,:,4)=F54.*F58;


out5=min(temp5,[],3);



m71=zeros(21);
m72=zeros(21);
m73=zeros(21);
m74=zeros(21);
m75=zeros(21);
m76=zeros(21);
m77=zeros(21);
m78=zeros(21);
m71(1:7,1:7)=1;
m72(1:7,8:14)=1;
m73(1:7,15:21)=1;
m74(8:14,15:21)=1;
m75(15:21,15:21)=1;
m76(15:21,8:14)=1;
m77(15:21,1:7)=1;
m78(8:14,1:7)=1;

LCM7=zeros(row,col,8);
LCM7(:,:,1)=localmean(img,m71);
LCM7(:,:,2)=localmean(img,m72);
LCM7(:,:,3)=localmean(img,m73);
LCM7(:,:,4)=localmean(img,m74);
LCM7(:,:,5)=localmean(img,m75);
LCM7(:,:,6)=localmean(img,m76);
LCM7(:,:,7)=localmean(img,m77);
LCM7(:,:,8)=localmean(img,m78);


F71=l7-reshape(LCM7(:,:,1),row,col);
F72=l7-reshape(LCM7(:,:,2),row,col);
F73=l7-reshape(LCM7(:,:,3),row,col);
F74=l7-reshape(LCM7(:,:,4),row,col);
F75=l7-reshape(LCM7(:,:,5),row,col);
F76=l7-reshape(LCM7(:,:,6),row,col);
F77=l7-reshape(LCM7(:,:,7),row,col);
F78=l7-reshape(LCM7(:,:,8),row,col);

temp7=zeros(row,col,4);
temp7(:,:,1)=F71.*F75;
temp7(:,:,2)=F72.*F76;
temp7(:,:,3)=F73.*F77;
temp7(:,:,4)=F74.*F78;


out7=min(temp7,[],3);


m91=zeros(27);
m92=zeros(27);
m93=zeros(27);
m94=zeros(27);
m95=zeros(27);
m96=zeros(27);
m97=zeros(27);
m98=zeros(27);
m91(1:9,1:9)=1;
m92(1:9,10:18)=1;
m93(1:9,19:27)=1;
m94(10:18,19:27)=1;
m95(19:27,19:27)=1;
m96(19:27,10:18)=1;
m97(19:27,1:9)=1;
m98(10:18,1:9)=1;

LCM9=zeros(row,col,8);
LCM9(:,:,1)=localmean(img,m91);
LCM9(:,:,2)=localmean(img,m92);
LCM9(:,:,3)=localmean(img,m93);
LCM9(:,:,4)=localmean(img,m94);
LCM9(:,:,5)=localmean(img,m95);
LCM9(:,:,6)=localmean(img,m96);
LCM9(:,:,7)=localmean(img,m97);
LCM9(:,:,8)=localmean(img,m98);


F91=l9-reshape(LCM9(:,:,1),row,col);
F92=l9-reshape(LCM9(:,:,2),row,col);
F93=l9-reshape(LCM9(:,:,3),row,col);
F94=l9-reshape(LCM9(:,:,4),row,col);
F95=l9-reshape(LCM9(:,:,5),row,col);
F96=l9-reshape(LCM9(:,:,6),row,col);
F97=l9-reshape(LCM9(:,:,7),row,col);
F98=l9-reshape(LCM9(:,:,8),row,col);

temp9=zeros(row,col,4);
temp9(:,:,1)=F91.*F95;
temp9(:,:,2)=F92.*F96;
temp9(:,:,3)=F93.*F97;
temp9(:,:,4)=F94.*F98;


out9=min(temp9,[],3);
temp=zeros(row,col,4);

temp(:,:,1)=out3;
temp(:,:,2)=out5;
temp(:,:,3)=out7;
temp(:,:,4)=out9;


re=max(temp,[],3);



end
