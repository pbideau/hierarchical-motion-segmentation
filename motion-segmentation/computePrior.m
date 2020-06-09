function [ bgPrior, fgPrior ] = computePrior( bgMaskPosterior, fgMaskPosterior, newMotionPosterior, OF, height, width, n, prevSegmentation, segm,numMotionComp_new )

    bgPrior = Posterior2Prior(bgMaskPosterior, OF, prevSegmentation);
    
    fgPrior = zeros(height, width, n);
    for i = 1:n
        fgPrior(:,:,i) = Posterior2Prior(fgMaskPosterior(:,:,i), OF, prevSegmentation);
    end
    
    newMotionPrior = Posterior2Prior(newMotionPosterior, OF, prevSegmentation);
    
    A = unique(segm);
    A = A(A~=1);
    if length(A)~=(max(A)-1)
        %which prior is missing???
        i_prior=1;
        for iv = 2:(max(A)-1)
            B = sum(A==iv); % 1 if value exists
            if B == 0
                fgPrior(:,:,iv-i_prior)=[];% remove uneffective prior
                i_prior = i_prior+1;
            end
        end
    end
    
    newMotionPrior = repmat(newMotionPrior,1,1,numMotionComp_new);
    fgPrior = cat(3, fgPrior, newMotionPrior);
    
end

