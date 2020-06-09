function [ locationPrior ] = computeLocationPrior( idx, H, W )

    locationPrior = zeros(H,W, length(idx));
    %Maybe dependent upon the size of the object or flow???
    var = ((H+W)/2)*0.05;
    
    for i = 1:length(idx)
       prior = zeros(H,W);
       prior(idx{i,:}) = 1;
       D = bwdist(prior);
       D(D>var) = var;
       D = abs(D./max(max(D))-1);
       
       locationPrior(:,:,i) = D.^2;
    end
    
    if isempty(idx)
        locationPrior = ones(H,W);
    end
    
end

