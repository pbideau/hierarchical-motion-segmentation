% ----------------------------------------------------------------
% setup VLFeat
% ----------------------------------------------------------------
run('./utils/vlfeat-0.9.20/toolbox/vl_setup')

% ----------------------------------------------------------------
% add path to motion segmentation code
% ----------------------------------------------------------------
addpath(genpath('./motion-segmentation'))

% ----------------------------------------------------------------
% specify your directories
% ----------------------------------------------------------------
pathCodeCRF = './utils/crf-motion-seg-master';
pathFrames = './samples/images/forest/';
pathFlow   = './samples/flow-classicNL/forest/';
pathResult = './samples/results/forest/';

% set this variable to true load precomputed initialization results already
% exist. If you run the code for the first time on a certain video you
% should set the calue to false.
loadInitRANSAC = true;

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
segmentation_Swarm(pathCodeCRF, pathFrames, pathFlow, pathResult, loadInitRANSAC)
