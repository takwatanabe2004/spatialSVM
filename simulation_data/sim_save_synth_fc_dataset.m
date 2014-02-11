% sim_save_synth_fc_dataset (01/07/2014)
% - create and save synthetic dataset
% - see sim_study_synth_fc.m to see how details on how we create the
%   synthetic functional connectome for simulation experiment
%==========================================================================
%--------------------------------------------------------------------------
%%
clear all
close all
load([get_rootdir,'/simulation_data/Results.mat'], 'ConnMean', 'ConnVar')
load([get_rootdir,'/simulation_data/graph_info347_2d.mat'], 'coord')
load([get_rootdir,'/simulation_data/sim_anom_node_info.mat'], 'anom_nodes')

%% set save options
% fsave=true;
fsave=false;
%% set options
%-------------------------------------------------------------------------%
% set SNR devel (same as cohen's d) http://en.wikipedia.org/wiki/Cohen%27s_d#Cohen.27s_d 
% http://www.3rs-reduction.co.uk/html/6__power_and_sample_size.html
%-------------------------------------------------------------------------%
snr=0.6;

%-------------------------------------------------------------------------%
% Set number of training subjects
% - nHC_tr = number of training control samples 
% - nDS_tr = number of training patient samples
% -   n_tr = number of training samples
%-------------------------------------------------------------------------%
nHC_tr = 100;
nDS_tr=nHC_tr;
ntr=nHC_tr+nDS_tr;

%-------------------------------------------------------------------------%
% Set number of test subjects
% - nHC_ts = number of training control samples 
% - nDS_ts = number of training patient samples
% -   n_ts = number of training samples
%-------------------------------------------------------------------------%
nHC_ts = 250;
nDS_ts=nHC_ts;
nts=nHC_ts+nDS_ts;

%-------------------------------------------------------------------------%
% set seed value for replicability
%-------------------------------------------------------------------------%
seedPoint=0;
randn('seed',seedPoint)
%% save path
outPath=[get_rootdir,'/simulation_data/sim_dataset_snr',num2str(snr),'.mat'];

outVars={'sim_info','Xtr','Xts','ytr','yts','timeStamp','mFileName'};
% return
%% relevant info
ConnMeanVec = tak_dvec(ConnMean);
ConnVarVec  = tak_dvec(ConnVar);
p=length(ConnMeanVec);
%% create dataset set
%==========================================================================
% create -1 (HC) control subjects
%==========================================================================
X_HC_tr = repmat(ConnMeanVec(:)',[nHC_tr,1])+ ...
          repmat(sqrt(ConnVarVec(:))',[nHC_tr,1]).*randn(nHC_tr,p);
X_HC_ts = repmat(ConnMeanVec(:)',[nHC_ts,1])+ ...
          repmat(sqrt(ConnVarVec(:))',[nHC_ts,1]).*randn(nHC_ts,p);

% inverse fisher tx to map to (-1,+1) correlation space
X_HC_tr = tak_fisher_itransformation(X_HC_tr);
X_HC_ts = tak_fisher_itransformation(X_HC_ts);

% Whos,return
%==========================================================================
% create +1 (DS) disease subjects
%==========================================================================
X_DS_tr = repmat(ConnMeanVec(:)',[nDS_tr,1])+ ...
          repmat(sqrt(ConnVarVec(:))',[nDS_tr,1]).*randn(nDS_tr,p);
X_DS_ts = repmat(ConnMeanVec(:)',[nDS_ts,1])+ ...
          repmat(sqrt(ConnVarVec(:))',[nDS_ts,1]).*randn(nDS_ts,p);
      
% add SIGNAL on connections between the two anomalous node clusters
for i=1:length(anom_nodes.idx_conn)
    % connection index
    idx=anom_nodes.idx_conn(i);
    
    % signal based on cohen's D (aka snr)
    SIGNAL=snr*sqrt(ConnVarVec(idx));
    
    % add SIGNAL on the connection between the anomalous node clusters
    X_DS_tr(:,idx)=X_DS_tr(:,idx) + repmat(SIGNAL,[nDS_tr,1]);
    X_DS_ts(:,idx)=X_DS_ts(:,idx) + repmat(SIGNAL,[nDS_ts,1]);
end
% inverse fisher tx to map to (-1,+1) correlation space
X_DS_tr = tak_fisher_itransformation(X_DS_tr);
X_DS_ts = tak_fisher_itransformation(X_DS_ts);

% concatenate X_DS and X_HC to get our training and testing design matrix
Xtr=[X_DS_tr; X_HC_tr];
Xts=[X_DS_ts; X_HC_ts];

% label vector for our training data
ytr=[+ones(nDS_tr,1); -ones(nHC_tr,1)]; 
yts=[+ones(nDS_ts,1); -ones(nHC_ts,1)]; 

%==========================================================================
% pool relevant info into a struct
%==========================================================================
sim_info.nDS_tr=nDS_tr;
sim_info.nHC_tr=nHC_tr;
sim_info.ntr=ntr;

sim_info.nDS_ts=nDS_ts;
sim_info.nHC_ts=nHC_ts;
sim_info.nts=nts;

sim_info.snr=snr;
sim_info.seedPoint=seedPoint;
sim_info.anom_nodes=anom_nodes;
%% save
if fsave
    timeStamp=datestr(now);
    mFileName=mfilename;
    save(outPath,outVars{:})
end