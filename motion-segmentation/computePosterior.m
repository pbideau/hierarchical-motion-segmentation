function [bgMaskPosterior, fgMaskPosterior, newMotionPosterior] = computePosterior( likelihood_bg, likelihood_fg, likelihood_newMotion, bgPrior, fgPrior, n, newPrior)

    %Smooth the prior
    fLength = 7;
    filter = fspecial('gaussian', fLength, fLength/4);

    [bgPriorNorm, fgPriorNorm, newPrior] = normalizePriors(bgPrior, fgPrior, newPrior, n);
    
    bgPrior = imfilter( bgPriorNorm, filter,'replicate');   
    fgPrior = imfilter( fgPriorNorm, filter,'replicate');

    [bgPriorNorm, fgPriorNorm, newPrior] = normalizePriors(bgPrior, fgPrior, newPrior, n);
    
    denominator = ((likelihood_bg.*bgPriorNorm) + sum((likelihood_fg(:,:,1:n).*fgPriorNorm(:,:,1:n)),3)+likelihood_newMotion.*newPrior)+eps;
    
    %Posteriors for each motion component and BG
    bgMaskPosterior = (likelihood_bg.*bgPriorNorm)...
        ./denominator;
    
    fgMaskPosterior = (likelihood_fg(:,:,1:n).*fgPriorNorm(:,:,1:n))...
        ./repmat(denominator,1,1,n);
    
    newMotionPosterior = (likelihood_newMotion.*newPrior)...
        ./denominator;
    
end


