function [ idx_MotionComp, prior, listMotionComp_current, segmentation_labelsTracked] = update_idx_MotionComp(segmentation_labelsTracked, prior, flow, minNumPixels, listMotionComp_current)

    labels = unique(segmentation_labelsTracked); 
    bin = zeros(size(segmentation_labelsTracked));
    
    idx_MotionComp = cell(length(labels)-1, 1);
    i_prior = 1;
    
    for i = 1:length(labels)-1
        bin(segmentation_labelsTracked==labels(i)) = 1;
        bin_flowed = flowImg( bin, flow );
        if sum(sum(bin_flowed))> minNumPixels
            idx_MotionComp{i,:} = find(bin_flowed);
            i_prior = i_prior+1;
        else
            idx_MotionComp{i,:} = [];
            prior(:,:,i_prior) = []; %ERROR: Matrix index is out of range for deletion.
            listMotionComp_current(i_prior) = [];
            segmentation_labelsTracked(segmentation_labelsTracked==labels(i)) = labels(length(labels)); %removode object and replave by bg
        end
        bin = zeros(size(segmentation_labelsTracked));
    end
    
    if isempty(prior)
        prior = zeros(height, width);
    end
    
    
end

