% Last update: (07/25/2014)
%-------------------------------------------------------------------------%
% Note: make sure to run the script "init.m" in the very beginning.
%-------------------------------------------------------------------------%
% This package contains the codes for running the ADMM algorithm described
% in the paper ``Disease Prediction based on Functional Connectomes using 
% a Scalable and Spatially-Informed Support Vector Machine.'' 
% (please see: http://arxiv.org/abs/1310.5415)
%
% The synthetic data, as well as the scripts for generating them, can be 
% found in directory ./simulation_data.
%
% The real schizophrenia functional connectome dataset can be found in
% directory ./real_data
%-------------------------------------------------------------------------%
% "sim_run_admm.m" will run the ADMM algorithm for performing binary
% classification on the synthetic functional connectome.
%
% "real_run_admm.m" will run the ADMM algorithm for performing binary
% classification on the real functional connectome.
%
% Loss function supported:
%   1. hinge loss 
%   2. truncated least squares
%   3. huberized hinge loss
%
% Regularizers supported:
%   1. Elastic-net
%   2. GraphNet
%   3. Fused Lasso
%-------------------------------------------------------------------------%
