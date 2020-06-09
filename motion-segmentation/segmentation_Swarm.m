function [] = segmentation_Swarm(pathCodeCRF, pathFrames, pathFlow, pathResult, varargin)
    
    % Loading optional arguments
    object_bool = true;
    
    while ~isempty(varargin)
        switch lower(varargin{1})
              case 'object'
                  pathObjectSegmentations = varargin{2};
                  object_bool = true;
              otherwise
                  error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end

    %% parameters for noise model learned on FBMS-train
    % variance of flow and noise
    a = [7 6 5 4 3 2 1 0 -1 -2];
    b = [ -1 -2 -3 -4 -5 -6 -7 -8 -9 -10];
    paramA = 2.^a;
    paramB = 2.^b; %noise

    u = 6;
    j = 9;
    A = paramA(u);
    B = paramB(j); %for noise

    %% create lookUp table
    pM = lookUpM(A);
    pV = lookUpV(B);
    LookUpLikelihood = pM.*pV;
    LookUpLikelihood = sum(LookUpLikelihood,3);

    %% set all relevant paths to process the video
    pathResultObjectProb = strcat(pathResult, 'objectMotions/objectProb/');
    pathResultRigidMotionsProb = strcat(pathResult, 'rigidMotions/motionProb/');
    mkdir(pathResultObjectProb);
    mkdir(pathResultRigidMotionsProb);

    fprintf('Running segmentation\n');
    fprintf('frames are here: %s\n', pathFrames);
    fprintf('flows are here   : %s\n', pathFlow);
    fprintf('results go here: %s\n', pathResult);
    fprintf('----------------------------------------------------------------\n');

    %% load all flow paths
    listFlow = dir(fullfile(pathFlow, '*.mat'));
    listFlow = extractfield(listFlow, 'name')';

    for i = 1:length(listFlow)
        listFlow{i} = strcat(pathFlow,  listFlow{i});
    end

    %% load all frame paths
    listFrames = [dir(fullfile(pathFrames, '*.png')); dir(fullfile(pathFrames, '*.jpg'))];
    listFrames = extractfield(listFrames, 'name')';

    for i = 1:length(listFrames)
        listFrames{i} = strcat(pathFrames,  listFrames{i});
    end

    %% run segmentation
    [SegmentationCell, TransIdealCell, TransCell] = ...
        runSegmentation( listFlow, listFrames, pathResultObjectProb, pathResultRigidMotionsProb, pathResult, LookUpLikelihood, pathObjectSegmentations, pathCodeCRF, object_bool);

    fprintf( 'Segmentation finished\n' );

    %% create 4 panel video
    fprintf( 'Creating segmentation video...\n' );
    createOverlayVideo_4panel(listFrames, SegmentationCell, TransIdealCell, TransCell, pathResult, u, j);

    %% save (rigid) motion segmentations as png
    fprintf('save (rigid) motion segmentation as png... \n');
    for i = 1:length(SegmentationCell)
        segmentationOrig = uint8(cell2mat(SegmentationCell(i,3)));
        imwrite(segmentationOrig, sprintf('%s%s%05d.png',pathResult, 'rigidMotions/', i));
    end

    %% save moving object segmentations as png
    if object_bool == true
        fprintf('save moving object segmentation as png... \n');
        for i = 1:length(SegmentationCell)
            segmentationOrig = uint8(cell2mat(SegmentationCell(i,2)));
            imwrite(segmentationOrig, sprintf('%s%s%05d.png',pathResult, 'objectMotions/', i));
        end
    end

end
