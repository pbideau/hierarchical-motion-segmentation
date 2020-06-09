function [likelihood_object] = objectLikelihood( frame, list_objects2labels, likelihood_fg, likelihood_newMotion, likelihood_bg, segmentation_labelsTracked, segm, ind)

[h,w,~] = size(likelihood_bg);
list_objects2labels_frame = list_objects2labels(:, frame);
list_objects2labels_frame = list_objects2labels_frame(~cellfun(@isempty,list_objects2labels_frame));
numObjects = length(list_objects2labels_frame);

% stack of likelihoods corresponding to ind
L = cat(3, likelihood_newMotion, likelihood_fg, likelihood_bg);

% map motion component labels to idx of lilelihoods used in ind
for o = 1:numObjects
    labels = list_objects2labels_frame{o,1};
    numLabels = length(labels);
    labels_ind = zeros(numLabels,1);
    for l = 1:numLabels
        labels_ind(l) = unique(segm(segmentation_labelsTracked == labels(l)));
    end
    list_objects2labels_frame(o,2) = {labels_ind};
end

% build complex motion likelihood for each object, background stays simple
likelihood_object = zeros(h,w,numObjects);
for o = 1:numObjects
    ind_objects_s = zeros(h,w);
    ind_objects = zeros(h,w);
    labels_ind = list_objects2labels_frame{o,2};
    numLabels = length(labels_ind);
    for s = size(ind,3):-1:1
        for l=1:numLabels
            L_ind = L(:,:,labels_ind(l));
            ind_objects_s(ind(:,:,s)==labels_ind(l)) = L_ind(ind(:,:,s)==labels_ind(l));
        end
        ind_objects(ind_objects==0) = ind_objects_s(ind_objects==0);
        ind_objects_s = zeros(h,w,numObjects);
    end
    % all zeros in ind_objects should be replaced by a correct label
    likelihood_object(:,:,o)=ind_objects;
end



end

