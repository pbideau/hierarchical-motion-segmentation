function [ ind, numNewMotion, listObject_idx ] = uniqueLabelsForNewMotionComp( ind, numMotionComp_total, listObject_idx )
% -------------------------------------------------------------------------
% give each new motion component a unique Label
% -------------------------------------------------------------------------
    num = max(max(ind));
    newMotion = ind == 1;
    
    CC = bwconncomp(newMotion);
    numNewMotion = CC.NumObjects;
    
    
    ind(ind == (num)) = numMotionComp_total+numNewMotion+2;
    s = numMotionComp_total+2;
    
    for k = 1:numNewMotion
        PixelList = CC.PixelIdxList{k};
        ind(PixelList) = s;
        s = s+1;
    end
    
    ind = ind-1;
       
end

