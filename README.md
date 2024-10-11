# Alternated Brain State after Moral Decisions 

Code and data for **The alternated brain states**, accompanying the preprint: 

**E.,Wang, XJ, Xu, R., J. H, Wu (2024). The alternated brain states in resting state after moral decisions.** *bioRxiv* <br/>

<img src="README_graph/HMM_state.gif" alt="dynamics" /><br/>
___
## **Abstract**
Instances of dishonesty may induce feelings of anxiety or guilt, leading to evident "after-effects" that impact subsequent behaviour and neural activity. However, how constantly switching moral decisions affects the brain states and what behavioural variable is primarily responsible
for the changing effect is still unclear. This study aimed to investigate how moral decisions influence resting brain states using rs-fMRI data collected before and after an information-passing task involving dishonest choices with rewards. We used multimodal fMRI (task-fMRI and rs-fMRI) and behavioural data and utilized an advanced computational model called the Hidden Markov Model (HMM) to explore brain dynamics during this process.

___
## **Introduction**

## **Methodology**

<div align=center>
    <img src="README_graph/hmm_process.gif" alt="hmm process" style="width: 500px;" />  
</div>
<br/>
   
___
## **Code**

___

**This repository contains:**
```
root
 ├── ua_code # Main analysis code
 │    ├── HMM-MAR-master # External Matlab package for HMM
 │    ├── figures # directory containing all output figures from HMM analysis code
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
 │    ├── output_HMM # directory containing folder related to HMM output, like state activation, transition probability and so on
 │    │   ├── Brain_states # contains 10 states of activation
 │    │   │   ├── output_states_tian # tian network activation 
 │    │   │   ├── output_states_yeo # yeo network activation 
 │    │   │   ├── covars.mat # HMM 10 states covariance
 │    │   │   ├── Mean_states.mat # 10 state activation on tian+yeo network
 │    │   │   
 │    │   ├── C-H_scores # contain K = 2 to 10 cross-validated C-H score
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
 │    │   ├── TP # contains all subjects' state transition probability
 │    │   ├── Task # contains significant comparison pairs between task and post rest in each state 
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

**Note**: to properly run all scripts, you need to set the ua_code of this repository as your working directory.
___
## How to use
* To start replicate the figures, you should go to [HMM_analysis_All_in_one.m](ua_code/HMM_analysis_All_in_one.m).<br />

* In the code, you can find instructions to replicate all figures, remember to set [ua_code](ua_code) as the working directory and add [HMM-MAR_master](ua_code/HMM-MAR-master) folder and subfolder into the MatLab path.<br />

* In order to run the directional Network-Based Statistics (dNBS), you should enter "dNBS" in MatLab command line window, then follow the instruction provided in [HMM_analysis_All_in_one.m](ua_code/HMM_analysis_All_in_one.m) to execute dNBS.

* There are 2 python codes that need to run separately from Matlab. The first is the code for brain state visualization [Figure3.ipynb](ua_code/Figure3.ipynb). The second is for neurosynth decoding [neurosynth.ipynb](ua_code/neurosynth/neurosynth.ipynb).
___

For bug reports, please contact Eric Wang ([eric.wang2004nz@link.cuhk.edu.hk](mailto:eric.wang2004nz@link.cuhk.edu.hk), or through X [@ericwan53761434](https://x.com/ericwan53761434).


