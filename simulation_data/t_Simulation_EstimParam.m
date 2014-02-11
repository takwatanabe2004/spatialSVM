% t_Simulation_EstimParam.m (01/07/2014)
% - my version of creating the mean matrix and all that junk
% - sanity check conducted on Simulation_EstimParam_check.m
%==========================================================================
%--------------------------------------------------------------------------
%%
clear
close all

disp('-------------------------------------------------------------------')
disp('------- This script needs the functional connectome dataset: ------')
disp('------- the dataset will be released in the very near future ------')
disp('----------------------- (exit script) -----------------------------')
disp('-------------------------------------------------------------------')
return
load rcorr_design_censor X y
load yeo_info347 roiMNI

% z-slice coordinate we use for the simulation
z_used = 18;
nodemask=(z_used==roiMNI(:,3));
coord_used=roiMNI(nodemask,:);

nNodes=sum(nodemask);
edgemask = false(347);

for i=1:347
    for j=i:347
        if nodemask(i) && nodemask(j)
            edgemask(i,j)=true;
            edgemask(j,i)=true;
        end
    end
end
% imedge(edgemask)
edgemaskVec=tak_dvec(edgemask);

%==========================================================================
% extract healthy subjects from dataset
%==========================================================================
idx_HC=(y==-1);
X_HC=X(idx_HC,:);

%==========================================================================
% extract edges corresponding to the z-slice of interest
%==========================================================================
X_HC_mini = X_HC(:,edgemaskVec);

%==========================================================================
% map correlation to (-inf,+inf) via fisher tx
%==========================================================================
X_HC_mini_fisher = tak_fisher_transformation(X_HC_mini);

ConnMeanVec=mean(X_HC_mini_fisher)';
ConnVarVec=var(X_HC_mini_fisher,1)'; % normalize by 1/N...MLE

ConnMean=tak_dvecinv(ConnMeanVec,0);
ConnVar=tak_dvecinv(ConnVarVec,0);

mFileName=mfilename;
timeStamp=tak_timestamp;
% save('Results_tak.mat','ConnMean','ConnVar','edgemask','edgemaskVec','coord_used','roiMNI','nodemask','mFileName','timeStamp')
