function [ masks_motion, masks_motion_smooth ] =removeSharpmasks( masks, masks_smooth, motionSegm )

    [h,w,num] = size(masks);
    motionSegm_bin = zeros(h,w);
    motionSegm_bin(motionSegm~=1)=1;
    area_of_overlap = zeros(num,1);

    for i =1:num

        S = masks(:,:,i)+motionSegm_bin;
        area_of_overlap(i) = sum(sum(S==2));

    end

    [~, idx] = sort(area_of_overlap, 'descend');

    j=1; idx_keep = [];

    for i = 1:num

        S = masks(:,:,idx(i))+motionSegm_bin;
        area_of_overlap = sum(sum(S==2));
        if area_of_overlap > 0
            idx_keep(j) = idx(i);
            j = j+1;
        end
        motionSegm_bin(S==2)=0;

    end

    if isempty(idx_keep)
        masks_motion = [];
        masks_motion_smooth = [];
    else
        masks_motion = masks(:,:,idx_keep);
        masks_motion_smooth = masks_smooth(:,:,idx_keep);
    end

end