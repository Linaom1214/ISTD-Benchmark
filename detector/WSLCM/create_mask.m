function [mask1,mask2,mask3,mask4,mask5,mask6,mask7,mask8] = create_mask(c_size)

t_mask=zeros(3*c_size,3*c_size);

mask1=t_mask;
mask1(1:c_size,1:c_size)=ones(c_size,c_size);

mask2=t_mask;
mask2(1:c_size,c_size+1:2*c_size)=ones(c_size,c_size);

mask3=t_mask;
mask3(1:c_size,2*c_size+1:3*c_size)=ones(c_size,c_size);



mask4=t_mask;
mask4(c_size+1:2*c_size,2*c_size+1:3*c_size)=ones(c_size,c_size);

mask5=t_mask;
mask5(2*c_size+1:3*c_size,2*c_size+1:3*c_size)=ones(c_size,c_size);


mask6=t_mask;
mask6(2*c_size+1:3*c_size,c_size+1:2*c_size)=ones(c_size,c_size);


mask7=t_mask;
mask7(2*c_size+1:3*c_size,1:c_size)=ones(c_size,c_size);

mask8=t_mask;
mask8(c_size+1:2*c_size,1:c_size)=ones(c_size,c_size);

end