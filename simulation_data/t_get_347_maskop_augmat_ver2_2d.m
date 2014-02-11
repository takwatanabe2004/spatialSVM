% t_get_347_maskop_augmat_ver2_2d (01/07/2014)
% - code from t_get_347_maskop_augmat_ver2.m...modified for 2-d slice for simulation
%--------------------------------------------------------------------------
% - half of the mask in the masking matrix created in t_get_347_maskop_augmat.m 
%   is redundance since the augmentation matrix fills up half of the vectors by
%   zeros...so this script replace these redundant masking entries by zeroes.
% - this does not change the penalty value of the graphnet or fused-lasso, but
%   during the ADMM operation, I've found some speedup can be attained by
%   having more 'zeroes' in the masking operator.
% create and save augmentation matrix and masking vector b.
% most of the script from t_j24_create_maskop_347yeo_CRIT
%--------------------------------------------------------------------------
%%
clear all
close all

fsave=false;
%% this cell block is mostly identical to t_get_347_maskop_augmat.m
load([get_rootdir, '/simulation_data/graph_info347_2d.mat'],'adjmat','coord')

% randn('state',0)
d=coord.num_nodes;
p=d*(d-1)/2;
NSIZE=coord.NSIZE;

N=coord.N;

%==========================================================================
% - Create augmentation matrix A (1st and 2nd level combined)
% - Also create array-converted connectome signal W, and see if it agrees with
%   reshape(A*w,[NSIZE NSIZE])
%==========================================================================
w=randn(p,1);

W=zeros(N,N);
A=sparse(N^2,p);

cnt=1;
for jj=1:d
    if mod(jj,50)==0; jj, end;
    for ii=jj+1:d
        ix=coord.rlex(ii);
        iy=coord.rlex(jj);
        W(ix,iy)=w(cnt);

        idx=sub2ind([N N],ix,iy);
        A(idx,cnt)=1;
        cnt=cnt+1;
    end
end

%==========================================================================
% verify that the augmentation matrix does it's job, and also check
% if A'*A is identity
%==========================================================================
if isequal( reshape(W,[NSIZE NSIZE]), reshape(A*w,[NSIZE NSIZE]) ) && isequal(speye(p),A'*A)
    disp('Good!!!')
else
    error('welp...screwed up again...now go enjoy debugging...')
end
% return
% Apply brute force method create the neighborhood-graph (just as i did in t_create_6d_NN_adjmat.m)
%==========================================================================
% difference matrix created using the adjacency matrix created from t_get_347_graphinfo_2d.m
%==========================================================================
C_brute=tak_adjmat2incmat(adjmat);
L_brute=C_brute'*C_brute;

%==========================================================================
% non-circulant difference matrix defined on the final augmented space
%==========================================================================
C_noncirc=tak_diffmat([NSIZE NSIZE],0);
L_noncirc=C_noncirc'*C_noncirc;

%==========================================================================
% circulant difference matrix defined on the final augmented space
%==========================================================================
C_circ=tak_diffmat([NSIZE NSIZE],1);
L_circ=C_circ'*C_circ;

%% verify the "masked norm" gives the same graphnet & fused-lasso penalty values
%==========================================================================
% the penalty values using the standard difference matrix
% - ||Cw||^q_2, q={1,2}
%==========================================================================
w=randn(p,1);
% w=ones(p,1);
W=reshape(A*w,[NSIZE,NSIZE]);
diff_brute=C_brute*w;
gnet_brute=norm(diff_brute,2)^2
flasso_brute=norm(diff_brute,1)

%==========================================================================
% Create binary masking matrix to apply the circulant difference matrix
% - since this matrix is diagonal, just save vector b, which contains the
%   diagonal entry of the masking matrix B
%==========================================================================
support_mask=(W~=0);

Bx1=circshift(support_mask,[-1  0  0  0])-support_mask;
By1=circshift(support_mask,[ 0 -1  0  0])-support_mask;
Bx2=circshift(support_mask,[ 0  0 -1  0])-support_mask;
By2=circshift(support_mask,[ 0  0  0 -1])-support_mask;

Bx1=spdiag(Bx1(:)==0);
By1=spdiag(By1(:)==0);
Bx2=spdiag(Bx2(:)==0);
By2=spdiag(By2(:)==0);

% blkdiag can be slow for large sparse matrices
NN=N^2;
Bsupp=...
[          Bx1, sparse(NN,NN), sparse(NN,NN), sparse(NN,NN); ...
 sparse(NN,NN),           By1, sparse(NN,NN), sparse(NN,NN); ...
 sparse(NN,NN), sparse(NN,NN),           Bx2, sparse(NN,NN); ...
 sparse(NN,NN), sparse(NN,NN), sparse(NN,NN),           By2];

Bcirc=tak_circmask([NSIZE NSIZE]);
B=Bsupp*Bcirc;
b=logical(full(diag(B)));

%=========================================================================%
% Spatial penalty value computed using masking operation and circulant matrix
% - ||B*C_circ*A*w||^q_q, q={1,2}
%=========================================================================%
gnet_circ=norm(b.*(C_circ*W(:)),2)^2;
flasso_circ=norm(b.*(C_circ*W(:)),1);

%=========================================================================%
% Check if the two penalties are equal (up to numerical precision)
% - ||Cw||^q_2, q={1,2}
% - ||B*C_circ*A*w||^q_q, q={1,2}
%=========================================================================%
err_gnet=abs(gnet_brute-gnet_circ)
err_flasso=abs(flasso_brute-flasso_circ)
if err_gnet<1e-10 && err_flasso<1e-10
    disp('Same penalty value obtained')
else
    error('meh...go debug')
end
%% from here, the script diverges from the old one!
% remove 1's on the lexicographically upper-triangular part 
% (these are zero entries: the augmentation matrix zero entries here)
mask=ones(N^2,1);

ix=zeros( N*(N-1)/2,1);
iy=zeros( N*(N-1)/2,1);
cnt=0;
for lex1=1:N; % 2d lex-ind
    for lex2=lex1+1:N % 2d lex-ind
        cnt=cnt+1;
        ix(cnt)=lex1;
        iy(cnt)=lex2;
    end
end
% convert from 2d-subs to 1d ind
idx=sub2ind([N N],ix,iy);
mask(idx)=0;
mask=spdiag(mask);
mask=blkdiag(mask,mask,mask,mask);

B2=mask*Bsupp*Bcirc;
gnet_circ3=norm(B2*C_circ*W(:),2)^2;
flasso_circ3=norm(B2*C_circ*W(:),1);

%%%% sanity check %%%%
isequal(gnet_circ,gnet_circ3)
isequal(flasso_circ,flasso_circ3)

clear b 
b2=full(diag(B2));
%% save
timeStamp=datestr(now);
mFileName=mfilename

if fsave
    save augmat_mask347ver2_2d b A timeStamp mFileName
end
