function [ priors ] = computePrior_2ndLevel( posteriors,OF, prevSegmentation, segmentation_labelsTracked)

[H,W,C] = size(segmentation_labelsTracked);
priors = zeros(H,W,C);
priors = repmat(priors, 1,1,size(posteriors,3));

for i = 1:size(posteriors,3)
    priors(:,:,i) = Posterior2Prior(posteriors(:,:,i), OF, prevSegmentation);
end

end

