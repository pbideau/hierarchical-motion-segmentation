function [bgPrior, fgPrior, idx_MotionComp_next, dif_transformIdx2motionLabel, segmentation_labelsTracked, numMotionComp_total, segm] = trackMotionSegments(ind, minNumPixels, numMotionComp_total, dif_transformIdx2motionLabel, prevSegmentation, n, bgMaskPosterior, fgMaskPosterior, newMaskPosterior, OF, height, width)

% -------------------------------------------------------------------------
    % remove small new motion Components that were created
    % and assign unique label
    % ------------------------------------------------------------------------- 
    [ segm ] = removeSmallNewMotionComp(ind, minNumPixels);
    
    [ segmentation_labelsTracked, numMotionComp_new] = uniqueLabelsForNewMotionComp(segm, numMotionComp_total); %This is my segmentation!!!!!
    numMotionComp_total = numMotionComp_total+numMotionComp_new;
    
    % -------------------------------------------------------------------------
    % assign correct label values to each motion component
    % ------------------------------------------------------------------------- 
    numOldMotionComponents = unique(segmentation_labelsTracked);
    if (length(numOldMotionComponents)-1-numMotionComp_new)>0
        numOldMotionComponents=numOldMotionComponents(length(numOldMotionComponents)-1-numMotionComp_new);
    else
        numOldMotionComponents = 0;
    end

    for x = numOldMotionComponents:-1:1
        segmentation_labelsTracked(segmentation_labelsTracked == x) = x+dif_transformIdx2motionLabel(x);
    end
    listMotionComp_current = unique(segmentation_labelsTracked);
    listMotionComp_current = listMotionComp_current(1:length(listMotionComp_current)-1);
    
    % -------------------------------------------------------------------------
    % update idx_MotionComp by flowing motion components foreward
    % ------------------------------------------------------------------------- 
    % compute priors (for the next frame) by flowing forward posterior probabilities
    [ bgPrior, fgPrior ] = computePrior( bgMaskPosterior, fgMaskPosterior, newMaskPosterior, OF, height, width, n-1, prevSegmentation, segm, numMotionComp_new );
    % update motionComp list (for the next frame) flow forward and remove
    % if too small
    [idx_MotionComp_next, fgPrior, listMotionComp_current, segmentation_labelsTracked] = update_idx_MotionComp(segmentation_labelsTracked, fgPrior, OF, minNumPixels, listMotionComp_current); 
    
    if ~isempty(listMotionComp_current)
        dif_transformIdx2motionLabel = listMotionComp_current - [2:length(listMotionComp_current)+1]'+1;
    else
        dif_transformIdx2motionLabel = 0;
    end
    
    % -------------------------------------------------------------------------
    % STAGE 1: SEGMENTATION RESULT
    % -------------------------------------------------------------------------
    % give background motion component always lable 1
    segmentation_labelsTracked = segmentation_labelsTracked+1;
    segmentation_labelsTracked(segmentation_labelsTracked==max(max(segmentation_labelsTracked))) = 1;


end

