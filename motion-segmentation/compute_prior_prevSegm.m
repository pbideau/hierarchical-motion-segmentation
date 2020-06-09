function [  prior_prevSegm_new, prior_prevSegm_bg ] = compute_prior_prevSegm(list_objects2labels, prior_prevSegm, frame)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

numObjects = list_objects2labels(:,frame);
numObjects = numel(numObjects(~cellfun(@isempty, numObjects)));

[h,w,~] = size(prior_prevSegm);
prior_prevSegm_new = zeros(h,w,numObjects);
p=1;
n = 1;
for i=1:length(list_objects2labels(:,frame))
    if ~isempty(list_objects2labels{i, frame})
        if ~isempty(list_objects2labels{i, frame-1})
            prior_prevSegm_new(:,:,p) = prior_prevSegm(:,:,n);  
            n = n+1;
        else
            prior_prevSegm_new(:,:,p) = ones(h,w)./(1+numObjects);
        end
        p = p+1;
        
    else
        if ~isempty(list_objects2labels{i, frame-1})
            n = n+1;
        end
    end
end

prior_prevSegm_bg = prior_prevSegm(:,:,end);

end

