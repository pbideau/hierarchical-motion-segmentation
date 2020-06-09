function [object_priors] = computeObjectPrior(objectProposals_mask, objectProposal_mask_smooth, bg_posterior, list_objects2labels, object_idx, frame, numMotionComp, numObjects, prior_prevSegm, segmentation_labelsTracked, segmentation)

object_priors_bg = bg_posterior;

%transform objectProposals_mask (binary) to a smooth location prior
[H,W,C] = size(objectProposals_mask);
locationPrior = objectProposals_mask;
var = ((H+W)/2)*0.1;
for i = 1:C
    D = bwdist(locationPrior(:,:,i));
    D(D>var) = var;
    D = abs(D./max(max(D))-1);
    locationPrior(:,:,i) = D.^2;
end


if ~isempty(objectProposals_mask)
    objectProposal_mask_smooth_orig = objectProposal_mask_smooth;
    locationPrior_orig = locationPrior;

    [~,idx] = sort(object_idx);
    object_idx_new = 1:length(object_idx);
    A = object_idx_new;
    object_idx_new(idx) = A;
    % get priors in right order fitting to likelihoods
    for i = 1:length(object_idx_new)
        objectProposal_mask_smooth(:,:,object_idx_new(i)) = objectProposal_mask_smooth_orig(:,:,i);
        locationPrior(:,:,object_idx_new(i)) = locationPrior_orig(:,:,i);
    end
    object_priors_fg = objectProposal_mask_smooth.^2;
    object_priors_fg = object_priors_fg.* locationPrior;
    object_priors_fg = object_priors_fg./max(max(max(object_priors_fg)));
    
    %numObjects that do not correspond necessarily to masks
    A = list_objects2labels(:,frame);
    A = A(~cellfun(@isempty, A));
    P = zeros(H,W,length(A));
    n = 1;
    s = 1;
    for o = 1:length(list_objects2labels(:,frame))
        if ~isempty(list_objects2labels{o,frame})
            if sum(ismember(o, object_idx))>=1
                P(:,:,n) = object_priors_fg(:,:,s);
                n = n+1;
                s= s+1;
            else
                % make a mask based on 1. stage segmentation
                o_labels = list_objects2labels{o,frame};
                mask=ismember(segmentation_labelsTracked,o_labels);
                D = bwdist(mask);
                D(D>var) = var;
                D = abs(D./max(max(D))-1);
                mask_prior = D.^2;
                P(:,:,n) = mask_prior;%ones(size(object_priors_bg));
                n = n+1;
            end
        end
    end
    
    object_priors_fg = P;
    
else
    C = list_objects2labels(:,frame);
    numPrior = C(~cellfun(@isempty, C));
    objectProposal_mask_smooth = ones(size(object_priors_bg));
    objectProposal_mask_smooth = repmat(objectProposal_mask_smooth,1,1,size(numPrior,1)) .* 1;%(1/(1+numObjects));%numMotionComp;
    object_priors_fg = objectProposal_mask_smooth;
end


if frame>1
    %get right amount of prior prev segmentation
    [prior_prevSegm_fg, prior_prevSegm_bg] = compute_prior_prevSegm(list_objects2labels, prior_prevSegm, frame);
    
    %supress 0 and ones to make the prior weaker otherwise they can cancel
    %each other out
    prior_prev_scaled = cat(3, prior_prevSegm_fg, prior_prevSegm_bg);
    prior_object_scaled = cat(3, object_priors_fg, object_priors_bg);
    a = 0.05;
    b = 0.95;
    a1 = 0.05;
    b1 = 0.95;
    min_val = 0;
    max_val = 1;
    prior_prev_scaled = ((b1-a1)*(prior_prev_scaled-min_val))/(max_val-min_val) + a1;
    prior_object_scaled = ((b-a)*(prior_object_scaled-min_val))/(max_val-min_val) + a;

    object_priors = prior_prev_scaled .* prior_object_scaled;

    norm = repmat(1./sum(object_priors,3),1,1,size(object_priors,3));
    object_priors = norm .* object_priors;

    object_priors_fg = object_priors(:,:,1:(end-1));
    object_priors_bg = object_priors(:,:,end);

    object_priors_fg(isnan(object_priors_fg)) = 0;
    object_priors_bg(isnan(object_priors_bg)) = 1;

    %Smooth the prior
    fLength = 7;
    filter = fspecial('gaussian', fLength, fLength/4);
    object_priors_bg = imfilter( object_priors_bg, filter,'replicate');
    object_priors_fg = imfilter(object_priors_fg, filter,'replicate');
end
%normalize (second time)
object_priors = cat(3,object_priors_fg, object_priors_bg);
norm = repmat(1./sum(object_priors,3),1,1,size(object_priors,3));
object_priors = norm .* object_priors;

end

