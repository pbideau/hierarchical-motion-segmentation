function [ SegmentationCell, TransIdealCell, TransCell] = motionSegmentation( dirFlow, rotation_ABC, translation_UVW, LookUpLikelihood, focallength_px, dirResult, dirFrame, pathSharpmask, pathObjectProb, pathResultRigidMotions, path, height, width, object_bool )
% INPUT: video name of the video.
%                   Example: video   'forest'
%                            when frames are named with forest_xxxxx.png'
%        firstidxOF number of the first optical flow matrix (often 1)                 
%        lastidxOF  number of last optical flow matrix, this is the number
%                   of the last videoframe-1
%        TransAF_ideal_bg_Initial
%                   estimated translational anglefiel based on the first
%                   opticalflow
%        RotadjustedOF_Initial
%                   Transalational opticalflow of first and second frame
%        RotadjustedAF_Initial
%                   Anglefield of transalational opticalflow of first and second frame
%        pE         modified Bruss and Horn error

rng default

%minimal effectivness metric
OtsusThresh = 0.7;
%a maximum of 15 motion components can be observed in the first frame
%(will be dynamicaly increased throughout the video)
maxNumMotions = 15;
%a singel motion component must contain at least minNumPixels pixels
minNumPixels = round(0.0001*height*width);
%lookuptable difference between each row or column (stepsize)
step_r = 0.07;
step_theta = 0.1;

numFlow = length(dirFlow);
SegmentationCell = cell(numFlow, 5);
TransIdealCell = cell(numFlow, 1);
TransCell = cell(numFlow, 1);
AngleDifCell = cell(numFlow, 1);
MagnCell = cell(numFlow, 1);
ImgSegmented = zeros(height, width);
prevSegmentation = ones(height, width);
list_labels2objects = cell(1,1);
list_objects2labels = cell(1,1);
list_labels2objects_time = cell(1,1);
list_objects2labels_time = cell(1,1);
prior_prevSegm = [];

xmin = floor(-(width-1)/2);
xmax = floor((width-1)/2);
ymin = floor(-(height-1)/2);
ymax = floor((height-1)/2);
x_comp = repmat(xmin:xmax, height, 1);
y_comp = repmat((ymin:ymax).', 1, width);

% -------------------------------------------------------------------------
% Output: Text
% -------------------------------------------------------------------------
fprintf('Segmenting video...\n');

for i=1:numFlow

    tic;
    
    INPUT_IMAGE_FILE = dirFrame{i};
    INPUT_PROB_MOTION_MAT_FILE = strcat(pathResultRigidMotions, sprintf('%05d.mat', i));
    OUTPUT_PROB_MOTION_MAT_FILE = strcat(pathResultRigidMotions, sprintf('crf-%05d.mat', i));
    INPUT_PROB_MAT_FILE = strcat(pathObjectProb, sprintf('%05d.mat', i));
    OUTPUT_PROB_MAT_FILE = strcat(pathObjectProb, sprintf('crf-%05d.mat', i));
    OF = load(dirFlow{i});
    OF = OF.uv;
       
    if (i == 1)     
        % -------------------------------------------------------------------------
        % Segmentation using Otsus method (first frame only)
        % -------------------------------------------------------------------------
        [RotOF] = getRotofOF( rotation_ABC, x_comp, y_comp, focallength_px);
        RotadjustedOF = OF - RotOF;
        RotadjustedAF = anglefield(RotadjustedOF);

        % find best fitting translational anglefield to anglefieldTransOF 
        TransOF_ideal(:,:,1) = -translation_UVW(1).*focallength_px+x_comp.*translation_UVW(3);
        TransOF_ideal(:,:,2) = -translation_UVW(2).*focallength_px+y_comp.*translation_UVW(3);

        [TransAF_ideal_bg] = anglefield(TransOF_ideal);
        
        [ fgPrior, idx_MotionComp, bgPrior] = ...
            findMotionComp_firstFrame( RotadjustedAF,  TransAF_ideal_bg, RotadjustedOF, OtsusThresh, maxNumMotions, minNumPixels);
        
        numMotionComp_total = length(idx_MotionComp);
        dif_transformIdx2motionLabel = zeros(length(idx_MotionComp),1);
        
        numObjects = length(idx_MotionComp);
    else
        % -------------------------------------------------------------------------
        % computation of the camera motion given the optical flow of frame i and i+1 and a
        % mask (1-ImgSegmented), which is an estimate for static background.
        % -------------------------------------------------------------------------
        [ rotation_ABC, translation_UVW] = CameraMotion( OF, bg_mask, rotation_ABC, focallength_px );
        
        [RotOF] = getRotofOF( rotation_ABC, x_comp, y_comp, focallength_px);
        RotadjustedOF = OF - RotOF;
        RotadjustedAF = anglefield(RotadjustedOF);

        % find best fitting translational anglefield to anglefieldTransOF 
        TransOF_ideal(:,:,1) = -translation_UVW(1).*focallength_px+x_comp.*translation_UVW(3);
        TransOF_ideal(:,:,2) = -translation_UVW(2).*focallength_px+y_comp.*translation_UVW(3);

        TransAF_ideal_bg = anglefield(TransOF_ideal);
    end
    
    magn = sqrt((RotadjustedOF(:,:,1)).^2+(RotadjustedOF(:,:,2)).^2);
    magn_Vec = reshape(magn, height*width, 1);

    idx_MotionComp = idx_MotionComp(~cellfun('isempty',idx_MotionComp)) ;
    n = length(idx_MotionComp)+1;
  
    % -------------------------------------------------------------------------
    % ith motion component likelihood:  
    % -------------------------------------------------------------------------
    [ likelihood_fg ] = flowLikelihood_motionComponents( idx_MotionComp, RotadjustedOF, height, width, x_comp, y_comp, RotadjustedAF, LookUpLikelihood, magn_Vec, step_r, step_theta, focallength_px);  
    [ locationPrior ] = computeLocationPrior( idx_MotionComp, height, width );
    fgPrior = fgPrior.*locationPrior;

    % -------------------------------------------------------------------------
    % static background likelihood:  
    % -------------------------------------------------------------------------
    Dif_Angle_bg = angleDifference(RotadjustedAF, TransAF_ideal_bg);
    likelihood_bg = flowLikelihood( LookUpLikelihood, Dif_Angle_bg, magn_Vec, height, width, step_r, step_theta);
    
    % -------------------------------------------------------------------------
    % likelihood of a new motion component
    % -------------------------------------------------------------------------
    likelihood_newMotion = flowLikelihood_newMotion( LookUpLikelihood, magn_Vec, height, width, step_r );
    newPrior = (1/(n+1)).*ones(height, width); 
    
    % -------------------------------------------------------------------------
    % Segmentation using Bays rule
    % ------------------------------------------------------------------------- 
    [bgMaskPosterior, fgMaskPosterior, newMaskPosterior] = ...
        computePosterior( likelihood_bg, likelihood_fg, likelihood_newMotion, bgPrior, fgPrior, n-1, newPrior);
    
    bgPosterior_crf = improve_posteriors_crf( INPUT_IMAGE_FILE, INPUT_PROB_MOTION_MAT_FILE, OUTPUT_PROB_MOTION_MAT_FILE, bgMaskPosterior, path );
    
    AllPosteriors = cat(3, newMaskPosterior, fgMaskPosterior, bgMaskPosterior);
    [~, ind] = sort(AllPosteriors, 3);
    
    if sum(sum(ind(:,:,n+1)==n+1))<=minNumPixels
        msgID = 'MYFUN:BadIndex';
        msg = sprintf('Motion component took over complete frame.\n Result can not be saved in %s.\n , frame:%d\n  ', dirResult, i);
        baseException = MException(msgID,msg);
        throw(baseException);
    end

    % -------------------------------------------------------------------------
    % STAGE 1: MOTION SEGMENTATION RESULT
    % -------------------------------------------------------------------------
    [bgPrior, fgPrior, idx_MotionComp_next, dif_transformIdx2motionLabel, segmentation_labelsTracked, numMotionComp_total, segm] = trackMotionSegments(ind, minNumPixels, numMotionComp_total, dif_transformIdx2motionLabel, prevSegmentation, n, bgMaskPosterior, fgMaskPosterior, newMaskPosterior, OF, height, width);
     
    
    if object_bool == true
        % -------------------------------------------------------------------------
        % compute object proposals using sharpmask: https://github.com/facebookresearch/deepmask
        % ------------------------------------------------------------------------- 
        [ objectProposals_mask, objectProposal_mask_smooth ] = objectProposal( numObjects, 1-AllPosteriors(:,:,n+1), pathSharpmask, i );

        % -------------------------------------------------------------------------
        % remove objects not covering motion components
        % -------------------------------------------------------------------------
        [objectProposals_mask, objectProposal_mask_smooth] = removeSharpmasks(objectProposals_mask, objectProposal_mask_smooth, segmentation_labelsTracked);

        % -------------------------------------------------------------------------
        % assign each motion component to an object
        % -------------------------------------------------------------------------
        [ list_labels2objects, list_objects2labels, list_labels2objects_time, list_objects2labels_time, objectProposals_mask, objectProposal_mask_smooth, object_idx ] = labels2objects_sharpmask( objectProposals_mask, segmentation_labelsTracked, list_labels2objects,list_objects2labels, list_labels2objects_time, list_objects2labels_time, i, objectProposals_mask, objectProposal_mask_smooth );

        % -------------------------------------------------------------------------
        % object likelihood:  
        % -------------------------------------------------------------------------
        object_likelihoods = objectLikelihood( i, list_objects2labels_time, likelihood_fg, likelihood_newMotion, likelihood_bg, segmentation_labelsTracked, segm, ind);
        object_likelihoods = cat(3, object_likelihoods, likelihood_bg);

        [object_priors] = computeObjectPrior(objectProposals_mask, objectProposal_mask_smooth, AllPosteriors(:,:,n+1), list_objects2labels_time, object_idx, i, size(ind,3), numObjects, prior_prevSegm, segmentation_labelsTracked, ind(:,:,n+1));

        % -------------------------------------------------------------------------
        % Segmentation using Bays rule
        % ------------------------------------------------------------------------- 
        denominator = repmat(sum(object_likelihoods.*object_priors, 3), 1, 1, size(object_likelihoods,3));
        posterior_objectA = (object_likelihoods.*object_priors)./denominator;

        % -------------------------------------------------------------------------
        % refinement using a CRF
        % ------------------------------------------------------------------------- 
        posterior_object = improve_posteriors_crf( INPUT_IMAGE_FILE, INPUT_PROB_MAT_FILE, OUTPUT_PROB_MAT_FILE, posterior_objectA, path );

        [~, ind_objects] = sort(posterior_object, 3);
        numObjects = numel(unique(ind_objects(:,:,size(ind_objects,3))))-1;

        [ prior_prevSegm ] = computePrior_2ndLevel( posterior_objectA, OF, prevSegmentation, segmentation_labelsTracked );

        % -------------------------------------------------------------------------
        % STAGE 2: OBJECT SEGMENTATION RESULT
        % -------------------------------------------------------------------------
        [ objectSegmentation ] = assignObjectIdx( ind_objects(:,:,end), list_objects2labels_time, i );

        %ImgSegmented(ind(:,:,n+1)==max(max(ind(:,:,n+1)))) = 1;

        if ~isempty(objectProposals_mask)
            sharpmask_segmentation = sum(objectProposals_mask,3);
            sharpmask_segmentation(sharpmask_segmentation>0)=255;
        else
            sharpmask_segmentation = zeros(size(objectSegmentation));
        end
    else
        sharpmask_segmentation = [];
        objectSegmentation = [];
        objectProposals_mask = [];
        posterior_object = [];
    end
    
    ImgSegmented(ind(:,:,n+1)==max(max(ind(:,:,n+1)))) = 1;
    
    SegmentationCell(i,1) = {sharpmask_segmentation};
    SegmentationCell(i,2) = {objectSegmentation};
    SegmentationCell(i,3) = {segmentation_labelsTracked};
    SegmentationCell(i,4) = {objectProposals_mask};
    SegmentationCell(i,5) = {posterior_object};
    TransIdealCell(i) = {TransAF_ideal_bg};
    TransCell(i) = {RotadjustedAF};
    AngleDifCell(i) = {Dif_Angle_bg};
    MagnCell(i) = {magn};

    bg_mask = flowingBin(1-ImgSegmented, OF);
    bg_mask = 1-bg_mask;
    % -------------------------------------------------------------------------
    % Output: Text
    % -------------------------------------------------------------------------
    elapsed = toc;
    text = sprintf('%s%d/%d%s', 'frame ', i, numFlow, ' computed in %gsec\n');
    fprintf(text, elapsed);
    idx_MotionComp = idx_MotionComp_next;
    prevSegmentation = ImgSegmented;
    ImgSegmented = zeros(height, width);

end

end
    


