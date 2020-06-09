function [SegmentationCell, TransIdealCell, TransCell] = ...
        runSegmentation( dirFlow, dirFrame, pathObjectProb, pathResultRigidMotions, dirResult, LookUpLikelihood, pathSharpmask, path, object_bool) 
%
%        Do you want to run the code including RANSAC initialization? 
%        if yes set RANSAC true
         RANSAC = true;
%        Do you want to use precomputed results of the RANSAC initialization?
%        if yes set RANSACcomputed true
         precomputedVal = true;
%--------------------------------------------------------------------------

    if (RANSAC == false)
        precomputedVal = false;
    end
    
    OF = load(dirFlow{1});
    OF = OF.uv;
    [height, width, ~] = size(OF);

    % focal length in pixel = (f in [mm]) * (imagewidth in pixel) / (CCD width in mm)
    focallength_mm = 5;
    CCD_width_mm = 6.16;
    focallength_px = focallength_mm/CCD_width_mm * width;
    
    %% estimate camera motion (first frame)
    if(RANSAC == true)       
        dirInitial = sprintf('%sinit.mat',  dirResult);
        
        if(precomputedVal == false)
            [rotation_ABC, translation_UVW] = initialize( dirFrame{1}, dirFlow{1}, focallength_px);
            save(dirInitial, 'rotation_ABC', 'translation_UVW');  
        else
            load(dirInitial);
        end
    else
        [rotation_ABC, translation_UVW, ~] = CameraMotion( OF, ones(height, width), [0 0 0], focallength_px );
    end
        
    %% run segmentation (all frames)
    [ SegmentationCell, TransIdealCell, TransCell] = motionSegmentation( dirFlow, rotation_ABC, translation_UVW, ...
        LookUpLikelihood, focallength_px, dirResult, dirFrame, pathSharpmask, pathObjectProb, pathResultRigidMotions, path, height, width, object_bool );
end