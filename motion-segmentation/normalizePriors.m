function [bgPriorNorm, fgPriorNorm, newPrior] = normalizePriors(bgPrior, fgPrior, newPrior, n)

    %-----------------------------------------------
    % normalize priors such that they sum up to one
    %-----------------------------------------------
    norm = (bgPrior + sum(fgPrior,3))./(1-newPrior);
    bgPriorNorm  = (bgPrior)./norm;
    bgPriorNorm(isnan(bgPriorNorm)) = 1*(1-1/(n+2));
    norm = repmat(norm,1,1,n);
    if (n~=0)
        fgPriorNorm = (fgPrior)./norm;
        fgPriorNorm(isnan(fgPriorNorm)) = 0*(1-1/(n+2))/n;
    else
        fgPriorNorm = fgPrior;
    end

end

