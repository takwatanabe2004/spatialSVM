%-------------------------------------------------------------------------%
% This directory contains the "real schizophrenia" functional connectome 
% used in our paper.
%-------------------------------------------------------------------------%
% The following is the order of the scripts ran to generate the synthetic data:
%   yeo_info347_dilated5mm.mat
%       - contains the (X,Y,Z)-locations of centroids of the 347 nodes 
%         used in our connectome parcellation in MNI coordinate ("roiMNI"), as 
%         well as the corresponding network membership ("roiLabel"...key given
%         in variable "yeoLabels")
%
%   graph_info347.mat
%       - contains the adjacency matrix ("adjmat") that defines the 
%         6-d neighborhood set of the connectomes
%       - file created from t_get_347_graphinfo.m
%
%   augmat_mask347ver2.mat
%       - contains the "augmentation matrix" A and the diagonal entries
%         of the binary masking matrix B introduced in our paper
%       - file created from  t_get_347_maskop_augmat_ver2.m
%
%   rcorr_design_censor.mat
%       - contains the design matrix "X" and the corresonding labels "y"
%         (+1 indicates schizophrenic, -1 indicates control)
%
%   Overall.mat
%       - contains misc. info, including the index-set corresponding to the
%         10-fold cross-validation we used (see "Overall.CrossValidFold")
%-------------------------------------------------------------------------%