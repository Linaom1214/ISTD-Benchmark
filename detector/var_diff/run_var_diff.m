function out = run_vardiff(img)
    img=double(img);

    size_int=7;
    size_guard=11;
    size_ext=15;
    a=(size_guard-size_int)/2;

    maskg=ones(size_guard);
    maskg(a+1:size_guard-a,a+1:size_guard-a)=0;
    maskg=maskg/sum(maskg(:));
    maski=ones(size_int);
    maski=maski/sum(maski(:));

    D_MIM=imfilter(img,maski, 'replicate')-...
        imfilter(img,maskg,'replicate');


    DD_MIM=D_MIM>0;
    P_rem=double(DD_MIM).*D_MIM;

    V_i=stdfilt(img,logical(maski));

    maske=ones(size_ext);

    b=(size_ext-size_guard)/2;
    maske(b+1:size_ext-b,b+1:size_ext-b)=0;
    V_e=stdfilt(img,maske);

    mask_var=ones(size_int);
    mask_var(ceil(size_int/2),ceil(size_int/2))=0;
    mask_var=mask_var/sum(mask_var(:));

    V2_e=imfilter(V_e,mask_var,'replicate');
    M_vard=V_i-V2_e;
    MD_vard=M_vard>0;
    M_vard=double(MD_vard).*M_vard;

    out=img.*(P_rem.^2).*(M_vard.^2);
end

