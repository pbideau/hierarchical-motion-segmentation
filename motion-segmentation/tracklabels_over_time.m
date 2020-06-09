function  [list_labels2objects_time, list_objects2labels_time] = tracklabels_over_time(list_labels2objects, list_objects2labels, list_labels2objects_time, list_objects2labels_time, frame)

if frame == 1
    list_labels2objects_time = list_labels2objects;
    list_objects2labels_time = list_objects2labels;
else
    %list_objects2labels_time = list_objects2labels(:,1:(frame-1));
    for i = 1:length(list_labels2objects(:,frame))
        if ~isempty(list_labels2objects{i,frame})
            T = {list_labels2objects(i,1:frame)};
            T = cell2mat(T{1,1});
            if ~isempty(T)
                if numel(T) == 1 %if new label then assign it to that object its assigned to (not a new object)
                    current_label_of_new_comp = list_labels2objects{i,frame};
                    %did that label exist before?
                    if ismember(current_label_of_new_comp, cell2mat(list_labels2objects(1:(i-1), frame)))
                        A = cell2mat(list_labels2objects(1:(i-1),frame));
                        B = cell2mat(list_labels2objects_time(:,frame));
                        pos = find(A==current_label_of_new_comp);
                        B = B(pos);
                        values = unique(B);
                        instances = histc(B(:), values);
                        [~, idx] = max(instances);
                        list_labels2objects_time{i,frame} = values(idx);
                    else
                        list_labels2objects_time{i,frame} = list_labels2objects{i,frame};
                    end
                else
                    values = unique(T);
                    instances = histc(T(:),values);

                    [maxVal, idx] = max(instances); %if equal amount first in vector is picked
                    list_labels2objects_time{i,frame} = values(idx);
                end
            else
                % eventually else needed if there is anew label and it's
                % assigned to a new object, then it is perhaps nt an object it
                % should go to that object where most labels in that ground go

                list_labels2objects_time{i,frame} = list_labels2objects{i,frame};

            end
        end 
    end

     list_objects2labels_time(:,frame)={[]};

    for i = 1:length(list_labels2objects_time(:,frame))
        if ~isempty(list_labels2objects_time{i,frame})
            if list_labels2objects_time{i,frame}>length(list_objects2labels_time(:,frame))
                list_objects2labels_time(list_labels2objects_time{i,frame}, frame) = {i};
            else
                list_objects2labels_time(list_labels2objects_time{i,frame}, frame) = {[list_objects2labels_time{list_labels2objects_time{i,frame}, frame}; i]};
            end
        end 
    end
end

end

