# IMAPC

Code and data for the paper 'Imagery adds stimulus-specific sensory evidence to perceptual detection'. 

'Experiment_Code' contains the experimental code in jsPsych (https://www.jspsych.org/). It requires jsPsych version 6.1.0 installed in the same folder and img.zip (containing the stimulus images) to be unzipped. 

'Data' contains the contrast levels and responses per trial for all collected participants prior to exclusion.

'Analyses' contains all the analysis code used in the paper. Running the 'MasterWrapperFinal.m' script will read in the data, exclude participants based on exclusion criteria mentioned in the paper and produce the figures. We ran these scripts on Matlab version R2018b. 
