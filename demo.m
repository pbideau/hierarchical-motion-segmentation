% ----------------------------------------------------------------
% setup VLFeat
% ----------------------------------------------------------------
run('/home/pia/Documents/MATLAB/utils/vlfeat-0.9.20/toolbox/vl_setup')

% ----------------------------------------------------------------
% specify your directories
% ----------------------------------------------------------------
pathCodeCRF = '/home/pia/Documents/MATLAB/motion_git/utils/crf-motion-seg';
pathFrames = '/home/pia/Documents/data/complexBackground-multilabel/Images/forest/';
pathFlow   = '/home/pia/Documents/data/complexBackground-multilabel/OpticalFlow-classicNL/forest/';
pathObjectSegmentations = '/home/pia/Documents/data/complexBackground-multilabel/deepmask/forest/';
pathResult = '/home/pia/Documents/data/complexBackground-multilabel/Results/forest/';

% ----------------------------------------------------------------
% motion segmentation using precomputed object semgnetation masks
% ----------------------------------------------------------------
% The path to precomputed object Segmentations (pathObjectSegmentations) 
% has to be provided in order to run the second level segmentation
% incoorporating objectness knowledge into the segmentation procedure.
% Alternatively the code can be run as follows (motion only):
%
% segmentation_Swarm(pathCodeCRF, pathFrames, pathFlow, pathGroundtruth, pathResult)
%
% ----------------------------------------------------------------
segmentation_Swarm(pathCodeCRF, pathFrames, pathFlow, pathResult, 'object', pathObjectSegmentations)


