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
Next, follow the instructions below to train ANN for 30cm Sea Level Rise Scenario.

## Input Dataset

Download the training dataset for 30cm Sea Level Rise Scenario here:

| Study Scenario | Model      | File |
|------------------|:--------------:|:----------:|
|Existing        |CS3| [1](https://cadwr.box.com/s/5uia874mrcimrjngdm0t4yxajw52xd6e), [2](https://cadwr.box.com/s/km9uo19j3b2rpv3oavzr3gv36pca9u7n), [3](https://cadwr.box.com/s/vqopiss446y04bo4yw60nq7khwks6mfg) |
|Existing        |DSM2| [1](https://cadwr.box.com/s/tmdt6b9qr31h78is7kolylb42wahlaqc), [2](https://cadwr.box.com/s/rr2778cdlad4254isb1kjq0vnemzvgj5) |
|SMSCG        |CS3| [1](https://cadwr.box.com/s/z7io6720qi69bb1xvrtyk3n0g7kb2gce), [2](https://cadwr.box.com/s/xtu3o37ar016mokjq37xvv6d47syba9n), [3](https://cadwr.box.com/s/voaugx36d4kwvvtlcpu2af2y2lybfpjz) |
|SMSCG        |DSM2| [1](https://cadwr.box.com/s/7karo6zz6y0jvfdrcliqlmyyna1fb329), [2](https://cadwr.box.com/s/h8gkuhc1l7slukq9wpjzkvvc6npigqod) |
|PA6K        |CS3| [1](https://cadwr.box.com/s/aa3bp77o6jk40kgr3aty9it0xcbfprty), [2](https://cadwr.box.com/s/q0hgpwtawloeo0whzt4x6dlyeuy9dky4), [3](https://cadwr.box.com/s/t1ra0sazamcmxboxs5b6v355tyt0k4wu) |
|PA6K        |DSM2| [1](https://cadwr.box.com/s/dm47ufdjksyzk5ms1c6iaqlry1an5m0b), [2](https://cadwr.box.com/s/vkl5d8ed0aqwk3rrfdvhktfun029ye4e) |


## Running

The repo contains jupyter notebooks and python code in two files. The starting point for input preprocessing are DSS files from one or mor runs of CALSIM based DSM2 studies.


* Preprocessing. The [read_calsim_and_collate_inputs.ipynb](read_calsim_and_collate_inputs.ipynb) takes the .dss files and creates input and output csv files
* Training and Testing. The [ann_smscg_ff_calsim3_style.ipynb](ann_smscg_ff_calsim3_style.ipynb) uses the csv files and builds, trains, saves and tests the neural network



