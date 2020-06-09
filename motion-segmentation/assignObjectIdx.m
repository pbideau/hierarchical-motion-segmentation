function [ segmentation_objects_tracked ] = assignObjectIdx( ind_segmentation, list_objects2labels_time, frame )
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    segmentation_objects_tracked = zeros(size(ind_segmentation));
    object_list = list_objects2labels_time(:,frame);
    l_orig = 1;
    for i = 1:length(object_list)
        if ~isempty(object_list{i,1})
            segmentation_objects_tracked(ind_segmentation==l_orig) = i;
            l_orig = l_orig+1;
        end
    end
    
end

