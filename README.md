# Alternated Brain State after Moral Decisions 

Code and data for **The alternated brain states**, accompanying the preprint: 

**E, Wang., XJ, Xu., R, Jiang., H, Wu (2024). The alternated brain states in resting state after moral decisions.** *bioRxiv* <br/>
___

**This repository contains:**
```
root
 ├── ua_code # Main analysis code
 │    ├── HMM-MAR-master # External Matlab package for HMM
 │    ├── figures # directory containing all output figure from HMM analysis code
 │    ├── input_data # input data, contains fmri and behavioral data
 │    │   ├── Task # Contain task fmri data
 │    │   │    ├── subj_data # all subjects' data in task
 │    │   │    ├── activation_data.xlsx # all subjects' data summary
 │    │   │    ├── task.ipynb # for extracting the summary
 │    │   │
 │    │   ├── Behavioral_data.mat # Contain task behavioral data
 │    │   ├── MNI152lin_T1_2mm_brain.nii.gz # standard MNI mask
 │    │   ├── Tian_Subcortex_S1_3T_2009cAsym.nii.gz # Tian network
 │    │   ├── Yeo2011_17Networks_MNI152_FreeSurferConformed1mm.nii.gz # Yeo network
 │    │   
 │    │
 │    ├── neurosynth # neurosynth folder
 │    │   ├── neurosynth.ipynb # Main neurosynth code
 │    │   ├── State_activation # input for neurosynth
 │    │   ├── neurosynth_output # Contain neurosynth summary on all keywords
 │    │
 │    │
 │    ├── output_HMM # directory containing folder related to HMM output, like state activation, transition probability and so on
 │    │   ├── Brain_states # contain 10 states activation
 │    │   │   ├── output_states_tian # tian network activation 
 │    │   │   ├── output_states_yeo # yeo network activation 
 │    │   │   ├── covars.mat # HMM 10 states covariance
 │    │   │   ├── Mean_states.mat # 10 state activation on tian+yeo network
 │    │   │
 │    │   │
 │    │   ├── C-H_scores # contain K = 2 to 10 cross validated C-H score
 │    │   │   ├── K2
 │    │   │   ├── K3
 │    │   │   ├── K4
 │    │   │   ├── K5
 │    │   │   ├── K6
 │    │   │   ├── K7
 │    │   │   ├── K8
 │    │   │   ├── K9
 │    │   │   ├── K10
 │    │   │   
 │    │   │
 │    │   ├── HMM_Model_K10 # contain HMM model
 │    │   ├── TP # contain all subjects' state transition probability
 │    │   ├── Task # contain significant comparison paris between task and post rest in each state 
 │    │   ├── dNBS_settings # settings for dNBS
 │    │   │   ├── design_matrix.txt # paired-t design matrix
 │    │   │   ├── MNI.txt # a dummy co-ordinate just for visualizing state transition
 │    │   │   ├── nodeLabels.txt # a dummy node name for 10 states 
 │    │
 │    ├── Figure3.ipynb # code for visualizing brain states and covariances
 │    ├── fit_HMM.m # HMM fitting
 │    ├── HMM_analysis_All_in_one.m # Main analysis code
 │
 ├── NBSDirected1.0.1 # External Matlab package for dNBS

```

