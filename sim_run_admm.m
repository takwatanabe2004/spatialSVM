% sim_run_admm.m
%%
clear
close all

dataPath=[get_rootdir,'/simulation_data/sim_dataset_snr0.6.mat'];
dataVars={'sim_info','Xtr','ytr','Xts','yts'};
load(dataPath,dataVars{:})

%-------------------------------------------------------------------------%
% Select number of training samples (ceiling: sim_info.ntr)
% - subsample from the 200 training samples (so ntr=200 is the ceiling)
%-------------------------------------------------------------------------%
% number of training samples (max: 200)
ntr = 100;

% subsample
idx_plus=1:ntr/2;
idx_minu=sim_info.ntr/2+1:sim_info.ntr/2+ntr/2;
idx=[idx_plus,idx_minu];
ytr=ytr(idx);
Xtr=Xtr(idx,:);

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
options.lambda=2^-6;  
options.gamma =2^-8;     

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
options.termin.progress = 500;   % <- display "progress" (every k iterations...set to inf to disable)
options.termin.silence = false; % <- display termination condition

%-------------------------------------------------------------------------%
% information needed for data augmentation and fft tricks
% (only need for graphnet or fused lasso)
%-------------------------------------------------------------------------%
if strcmpi(penalty,'gnet') || strcmpi(penalty,'flas')
    load graph_info347_2d adjmat coord
    load augmat_mask347ver2_2d A b

    options.misc.NSIZE=[coord.NSIZE,coord.NSIZE];
    options.misc.A=A; % <- augmentation matrix
    options.misc.b=b; % <- masking vector
end

%% run ADMM
switch penalty
    case 'enet'
        output=tak_admm_elasticnet(Xtr,ytr,options);
    case 'gnet'
        output=tak_admm_graphnet(Xtr,ytr,options);
    case 'flas'
        output=tak_admm_fusedlasso(Xtr,ytr,options);
end
w=output.v2;

%-------------------------------------------------------------------------%
% evaluate test classification accuracy
%-------------------------------------------------------------------------%
% prediction 
ypr=SIGN(Xts*w);

% accuracy, TPR (true positive rate), TNR (true negative rate)
test_accuracy=tak_binary_classification_summary(ypr,yts)

%-------------------------------------------------------------------------%
% Display the estimated weight vector (reshaped into a symmetric matrix), 
% with the support mask indicating the location of the "anomalous edges"
%-------------------------------------------------------------------------%
figure, 
set(gcf,'Units','pixels','Position', [121 121 1400 800]) % for my windows7 lab computer
subplot(121),imagesc(tak_dvecinv(w,0)), axis('on','image');
cmap = [-1, 1]*max(abs(caxis))/4; caxis(cmap); colorbar('NorthOutside')
title('Estimated weight vector')
subplot(122),imagesc(sim_info.anom_nodes.mask),  axis('on','image');
caxis(cmap); colorbar('NorthOutside')
title('Anomalous edge support')