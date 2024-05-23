[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/dwr-psandhu/ann_calsim/HEAD)
# Python based ANN for CALSIM

This repo uses Python and Keras frameworks to build, train and test a neural network based on the paper. 

Nimal C. Jayasundara, et al. [Artificial Neural Network for Sacramento–San JoaquinDelta Flow–Salinity Relationship for CalSim 3.0](https://ascelibrary.org/doi/10.1061/%28ASCE%29WR.1943-5452.0001192)


## Setup
To try it on the cloud (mybinder.org) simply use [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/dwr-psandhu/ann_calsim/HEAD). 

To setup a local enviornment, first download miniconda3.

For preprocessing, create an environment based on [preprocess_environment.yml](environment.yml) file
```
conda env create -f preprocess_environment.yml
```

For ANN training, create an environment based on [environment.yml](environment.yml) file
```
conda env create -f environment.yml
```
Next, follow the instructions below

## Input Dataset

Download the training dataset from here:


## Running

The repo contains jupyter notebooks and python code in two files. The starting point for input preprocessing are DSS files from one or mor runs of CALSIM based DSM2 studies.


* Preprocessing. The [read_calsim_and_collate_inputs.ipynb](read_calsim_and_collate_inputs.ipynb) takes the .dss files and creates input and output csv files
* Training and Testing. The [ann_smscg_ff_calsim3_style.ipynb](ann_smscg_ff_calsim3_style.ipynb) uses the csv files and builds, trains, saves and tests the neural network



