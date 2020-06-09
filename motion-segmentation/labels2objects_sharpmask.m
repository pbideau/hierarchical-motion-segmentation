function [ list_labels2objects, list_objects2labels, list_labels2objects_time, list_objects2labels_time, objectProposals_mask, objectProposal_mask_smooth, object_idx ] = labels2objects_sharpmask( masks, motionSegm_labels, list_labels2objects, list_objects2labels, list_labels2objects_time, list_objects2labels_time, frame, objectProposals_mask, objectProposal_mask_smooth )
% masks are the output masks by sharpmasks. Sorted from high IoU to low IoU

[h, w, num] = size(masks);
motionSegm_object = zeros(h,w);
motionSegm_labels_temp = motionSegm_labels;
list_labels2objects_frame = cell(1,1);
list_objects2labels_frame = cell(num,1);

l_frame = unique(motionSegm_labels_temp);
l_frame(l_frame==1) = [];
l_frame(l_frame==0) = [];

u=1;
idx_remove = [];
list_best_object_num = [];

if frame==9
    a=1;
end

if  ~isempty(masks)
    l = unique(motionSegm_labels_temp);
    idx_remove = 1:num;
    for i = 2:length(l) %no bg
        segment_i = zeros(h,w);
        segment_i(motionSegm_labels_temp==l(i))=1;
        best_I = 0;
        intersection_exists = 0;
        %find highest IoU for each label
        for j = 1:num
            I = segment_i+masks(:,:,j);
            I = (I==2);
            I = sum(sum(I));
            if I>best_I
                best_I = I;
                intersection_exists = 1;
                best_object = j;
            end
        end
        if intersection_exists==1
            list_labels2objects_frame(l(i), 1) = {best_object};
            list_objects2labels_frame(best_object, 1) = {[list_objects2labels_frame{best_object, 1}; l(i)]};
            idx_remove(idx_remove==best_object) = [];
        end
    end
    
    list_objects2labels_frame = list_objects2labels_frame(~cellfun(@isempty, list_objects2labels_frame));
    numObjects = length(list_objects2labels(:,max(1,frame-1)));

    if frame ==1

        list_labels2objects = list_labels2objects_frame;
        list_objects2labels = list_objects2labels_frame;
        object_idx = 1:length(list_objects2labels_frame);

    else

        for i = 1:length(list_objects2labels_frame)
            similarity_prev = 0;
            similarity_rank = zeros(length(list_objects2labels_time(:,max(1,frame-1))),1);
            %new better stuff
            % idx of object2labels_frame that are assigned to a previous object
            [idx ] = similarity2objects( list_objects2labels_frame, list_objects2labels_time(:,max(1,frame-1)) );
            %not that great
            for k = 1:length(list_objects2labels_time(:,max(1,frame-1)))
                similarity = sum(ismember(list_objects2labels_frame{i, 1}, list_objects2labels_time{k,max(1,frame-1)}));
                similarity_rank(k) = similarity;
                if similarity_prev<similarity
                    similarity_prev = similarity;
                end

            end

            if idx(i) == 0 % then it might be a new object
                %did exist label x before? if yes same object id should be
                %assigned otherwise it is a new objecty
                %not sure wether this makes sense since an object that was
                %joined in frame-1 maybe should be separated...
                label_x = list_objects2labels_frame{i, 1};
                A = list_objects2labels_time(~cellfun(@isempty, list_objects2labels_time));
                [ A ] = getElementsOfCell( A );
                %A = cell2mat(A);
                if sum(ismember(A,label_x))>=1 %label existed before
                    % search for previous object id of label x
                    found_frame = 0;
                    frame_search = size(list_objects2labels_time,2);
                    while found_frame == 0
                        A = list_objects2labels_time(:,frame_search);
                        A = cell2mat(A);
                        if sum(ismember(A,label_x))>=1 %label existed in frame frame_search
                            %which object number was it?
                            A = list_objects2labels(:,frame_search);%time???
                            %found_frame = 1;
                            found_object = 0;
                            object_num = 1;
                            while object_num <= size(list_objects2labels,1)%found_object == 0
                                if sum(ismember(cell2mat(A(object_num,1)),label_x))>=1
                                    if size(list_objects2labels,2)<frame
                                        list_objects2labels(object_num, frame) = {list_objects2labels_frame{i, 1}};
                                        list_labels2objects(list_objects2labels_frame{i, 1}, frame) = {object_num};
                                        found_object = 1;
                                        found_frame = 1;
                                        object_num = size(list_objects2labels,1);
                                    else
                                        % I do not want to join components
                                        if sum(ismember(idx,object_num))==0
                                            list_objects2labels(object_num, frame) = {list_objects2labels_frame{i, 1}};
                                            list_labels2objects(list_objects2labels_frame{i, 1}, frame) = {object_num};
                                            found_object = 1;
                                            found_frame = 1;
                                            object_num = size(list_objects2labels,1);
                                        end

                                    end
                                    object_num = object_num+1;
                                    %found_object = 1;
                                else
                                    object_num = object_num+1;
                                end
                            end
                        end
                        frame_search =frame_search-1;
                        if (frame_search == 0) && (found_object == 0)
                             % create new object
                            numObjects = numObjects+1;
                            % assign each label object number i
                            list_labels2objects(list_objects2labels_frame{i, 1}, frame) = {numObjects};
                            % assign to object i set of labels
                            list_objects2labels(numObjects, frame) = {list_objects2labels_frame{i, 1}};  
                            object_num = numObjects;
                            found_object = 1;
                            found_frame = 1;
                        end
                    end
                    object_idx(i) = object_num;
                else
                    numObjects = numObjects+1;
                    % assign each label object number i
                    list_labels2objects(list_objects2labels_frame{i, 1}, frame) = {numObjects};
                    % assign to object i set of labels
                    list_objects2labels(numObjects, frame) = {list_objects2labels_frame{i, 1}};  
                    object_idx(i) = numObjects;
                end
            else
                % assign each label object number i
                list_labels2objects(list_objects2labels_frame{i, 1}, frame) = {idx(i)};
                % assign to object i set of labels
                if size(list_objects2labels,2)<frame
                    list_objects2labels(idx(i), frame) = {list_objects2labels_frame{i, 1}};
                else
                     if isempty(list_objects2labels(idx(i), frame))
                          list_objects2labels(idx(i), frame) = {list_objects2labels_frame{i, 1}};
                     else
                          list_objects2labels{idx(i), frame} = [list_objects2labels{idx(i), frame}; list_objects2labels_frame{i, 1}];
                     end
                end
                object_idx(i) = idx(i);
            end
        end
        
        %check for empty cells in list_objects2labels. The correct labels
        %might still exist it is just not covered by a objectproposal-mask
        %(make sure that this label wasn't used before)
        for i = 1:length(list_objects2labels(:, frame))
            if isempty(list_objects2labels{i,frame})
                lost_labels = list_objects2labels{i,frame-1};
                %lost label must exist also in current frame
                if sum(ismember(lost_labels,l_frame))>=1
                    A = ismember(lost_labels,l_frame);
                    lost_labels=lost_labels(A);
                    for l = 1:length(lost_labels)
                        if ismember(lost_labels(l),cell2mat(list_objects2labels(:,frame)))==0
                            labels = unique(motionSegm_labels);
                            if ismember(labels,lost_labels(l))>=0
                                list_objects2labels{i,frame} = [list_objects2labels{i,frame}; lost_labels(l)];
                                list_labels2objects{lost_labels(l), frame} = i;
                            end
                        end
                    end
                end
            end
        end

    end

    %remove object masks that do not cover a motion component, since it is
    %already covered by an other obejct mask
    objectProposals_mask(:,:,idx_remove) = [];
    objectProposal_mask_smooth(:,:,idx_remove) = [];
    [list_labels2objects_time, list_objects2labels_time] = tracklabels_over_time(list_labels2objects, list_objects2labels, list_labels2objects_time, list_objects2labels_time, frame);

    for i =1:length(list_objects2labels(:,frame))
        % if object i exists in frame
        if ~isempty(list_objects2labels{i,frame})
            for j = 1:length(list_objects2labels{i,frame})
                motionSegm_object(motionSegm_labels ==  list_objects2labels{i,frame}(j,1)) = i; 
            end
        end
    end

else
    
    %if we have no object proposal mask from sharpmask motion components
    %belong to the same object as in previous frame
    object_idx = [];
    list_objects2labels(:,frame)={[]};
    list_labels2objects(:,frame) = {[]};
    list_objects2labels_time(:,frame)={[]};
    list_labels2objects_time(:,frame) = {[]};
    if frame~=1
        for i = 1:length(l_frame)  
            for j = 1:length(list_objects2labels(:,frame-1)) %TODO: FAILS in first frame
                if ismember(l_frame(i), list_objects2labels{j,frame-1})
                    list_objects2labels(j, frame) = {[list_objects2labels{j, frame}; l_frame(i)]};
                    list_labels2objects(l_frame(i), frame) = {[j]};
                end
            end
            for j = 1:length(list_objects2labels_time(:,frame-1)) %TODO: FAILS in first frame
                if ismember(l_frame(i), list_objects2labels_time{j,frame-1})
                    list_objects2labels_time(j, frame) = {[list_objects2labels_time{j, frame}; l_frame(i)]};
                    list_labels2objects_time(l_frame(i), frame) = {[j]};
                end
            end
        end
    else
        % in first frame all labels form a signle object if no mask exists
        list_objects2labels(1, frame) = {l_frame};
        list_labels2objects(l_frame, frame) = {1};
        list_objects2labels_time(1, frame) = {l_frame};
        list_labels2objects_time(l_frame, frame) = {1};
    end
    
end

end

