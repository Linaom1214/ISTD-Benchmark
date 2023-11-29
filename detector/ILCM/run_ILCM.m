function re = run_ILCM( img )

img=double(img);
[nrows,ncols]=size(img);
reg_size=8;
stp_size=reg_size/2;
pad_nr=mod(nrows,stp_size);
pad_nc=mod(ncols,stp_size);
pad_r=0;
if (pad_nr ~= 0)
    pad_r=stp_size-pad_nr;
end
pad_c=0;
if (pad_nc ~= 0)
    pad_c=stp_size-pad_nc;
end
img_pad=padarray(img,[pad_r pad_c],'replicate','post');

[nrows1,ncols1]=size(img_pad);


a=ceil((nrows1-reg_size)/(stp_size))+1;
b=ceil((ncols1-reg_size)/(stp_size))+1;
M=zeros(a,b);
Ln=zeros(a,b);
for i=1:a
    for j=1:b
        temp=img_pad(stp_size*(i-1)+1:stp_size*(i-1)+reg_size,stp_size*(j-1)+1:stp_size*(j-1)+reg_size);
        Ln(i,j)=max(max(temp));
        M(i,j)=mean2(temp);
    end
end
Mi=imdilate(M,[1 1 1;1 0 1;1 1 1]);
out=Ln.*M;
re=out./Mi;
end


