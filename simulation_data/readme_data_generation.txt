%-------------------------------------------------------------------------%
% This directory contains the scripts used to generate the synthetic 
% functional connectome data.
% The resulting *.mat files are already saved on disk.
%-------------------------------------------------------------------------%
% The following is the order of the scripts ran to generate the synthetic data:
%   1. t_Simulation_EstimParam.m 
%       - compute sample mean and variance for the normal distribution
%       - output: Results.mat
%
%   2. t_get_347_graphinfo_2d.m 
%       - get the 4-D coordinate information of the synthetic connectome, 
%         as well as the adjacency matrix (adjmat)
%       - output: graph_info347_2d.mat
%
%   3. t_get_347_maskop_augmat_ver2_2d.m
%       - get the augmentation matrix 'A' and masking vector 'b' for computing
%         the spatial penalty ||B*C*A*w||_2^2 (note: B=diag(b))
%       - output: augmat_mask347ver2_2d.mat
%
%   4. sim_save_anomNode_setup.m
%       - get the index set representing the "anomalous edges"
%       - output: sim_anom_node_info.mat
%
%   5. sim_save_synth_fc_dataset.m
%       - generate the synthetic functional connectome data
%       - in the paper, the "snr" value was set at 0.6....feel free to 
%         change this "snr" value (this is equivalent to Cohen's effect size)
%       - output: sim_dataset_snr[SNRvalue].mat
%-------------------------------------------------------------------------%