% real_run_admm.m
%%
clear all; 
close all;

dataPath=[get_rootdir,'/real_data/rcorr_design_censor.mat'];
dataVars={'X','y'};
load(dataPath,dataVars{:})
[n,p]=size(X);

%-------------------------------------------------------------------------%
% Choose regularizer/penalty function
% - 'enet' = Elastic-net
% - 'gnet' = GraphNet
% - 'flas' = fused Lasso
%-------------------------------------------------------------------------%
% penalty = 'enet'; 
% penalty = 'gnet';
penalty = 'flas';

%-------------------------------------------------------------------------%
% Set penalty parameters
% - lambda = L1 regularization parameter:  
%       lambda*||w||_1
% - gamma  = second regularization parameter 
%  (meaning depends on the choice of 'penalty')
%       'enet' => gamma*||w||^2_2
%       'gnet' => gamma*||C*w||^2_2
%       'flas' => gamma*||C*w||_1
%-------------------------------------------------------------------------%
options.lambda=2^-9;  
options.gamma =2^-10;    

%-------------------------------------------------------------------------%
% loss function 
% - 'hinge1'   => hinge loss
% - 'hinge2'   => truncated least squares
% - 'hubhinge' => huberized hinge loss (must supply loss_huber_param as well)
%-------------------------------------------------------------------------%
options.loss='hinge1';
% options.loss_huber_param=0.2; % <- only needed when using huberized-hinge

%-------------------------------------------------------------------------%
% augmented lagrangian parameters
%-------------------------------------------------------------------------%
options.rho=1;

%-------------------------------------------------------------------------%
% termination criteria
%-------------------------------------------------------------------------%
options.termin.maxiter = 400;   % <- maximum number of iterations
options.termin.tol = 4e-3;      % <- relative change in the primal variable
options.termin.progress = 50;   % <- display "progress" (every k iterations...set to inf to disable)
options.termin.silence = false; % <- display termination condition

%-------------------------------------------------------------------------%
% information needed for data augmentation and fft tricks
% (only need for graphnet or fused lasso)
%-------------------------------------------------------------------------%
if strcmpi(penalty,'gnet') || strcmpi(penalty,'flas')
    load graph_info347 adjmat coord
    load augmat_mask347ver2 A b

    options.misc.NSIZE=[coord.NSIZE,coord.NSIZE];
    options.misc.A=A; % <- augmentation matrix
    options.misc.b=b; % <- masking vector
end
%% run ADMM
switch penalty
    case 'enet'
        output=tak_admm_elasticnet(X,y,options);
    case 'gnet'
        output=tak_admm_graphnet(X,y,options);
    case 'flas'
        output=tak_admm_fusedlasso(X,y,options);
end
w=output.v2;
%% look at the network structure of the support of the parameter
textOption1={'fontweight','b','fontsize',12};
lineOption = {'color','k','linewidth',0.5};

load yeo_info347_dilated5mm.mat yeoLabels roiMNI roiLabel

% circularly shift 1 indices
roiLabel=roiLabel-1;
roiLabel(roiLabel==-1)=12;
yeoLabels = circshift(yeoLabels,-1);

% sort rows/cols according to network membership with 0-diagonals
[idxsrt,labelCount] = tak_get_yeo_sort(roiLabel);
wmat=tak_dvecinv(w)-eye(347);
wmatsort=wmat(idxsrt,idxsrt);

figure,set(gcf,'Units','pixels','Position', [1 121 950 850]) % for my lap monitor
imtriag(wmatsort),axis off
tak_local_linegroups(gcf,labelCount,textOption1,lineOption),hold on

figure,set(gcf,'Units','pixels','Position', [951 121 950 850]) % for my lap monitor
imagesc(wmatsort), axis image off
tmp=max(abs(caxis)); caxis([-tmp,tmp]/5); % change color-range to improve visibility
tak_local_linegroups(gcf,labelCount,textOption1,lineOption)