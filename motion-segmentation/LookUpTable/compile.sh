#! /bin/bash

export PATH=/Applications/MATLAB_R2016b.app/bin:$PATH 
mcc -mv segmentation_Swarm.m \
    -d ./ \
    -o computeLookUpTable_swarm