### Matlab codes and Data for our NeuroImage paper
This repository contains the dataset and the Matlab codes for the ADMM algorithms described in our paper "Disease Prediction based on Functional Connectomes using a Scalable and Spatially-Informed Support Vector Machine" (<a href="http://www.ncbi.nlm.nih.gov/pubmed/24704268" target="_blank">PubMed</a>, <a href="http://arxiv.org/abs/1310.5415" target="_blank">arXiv</a>).

The synthetic data and the scripts for generating them can be found in ./simulation_data.  
The real schizophrenia functional connectome data can be found in ./real_data


####General remarks

- Loss function supported:
    1. hinge loss 
    2. truncated least squares
    3. huberized hinge loss
- Regularizers supported:
    1. Elastic-net
    2. GraphNet
    3. Fused Lasso
- Run the script `init.m` in the very beginning.
- `sim_run_admm.m` will run the ADMM algorithm for performing binary classification on the synthetic functional connectome.
- `real_run_admm.m` will run the ADMM algorithm for performing binary classification on the real functional connectome.


#### Data description
Data collection was performed at the Mind Research Network, and funded by a Center of Biomedical Research Excellence (COBRE) grant 5P20RR021938/P20GM103472 from the NIH to Dr. Vince Calhoun.  The COBRE data set can also be downloaded from the COllaborative Informatics and Neuroimaging Suite data exchange tool (COINS[1]; http://coins.mrn.org/dx).  

[1] A. Scott, W. Courtney, D. Wood, R. De la Garza, S. Lane, R. Wang, J. Roberts, J. A. Turner, and V. D. Calhoun, "COINS: An innovative informatics and neuroimaging tool suite built for large heterogeneous datasets," Frontiers in Neuroinformatics, vol. 5, pp. 1-15, 2011