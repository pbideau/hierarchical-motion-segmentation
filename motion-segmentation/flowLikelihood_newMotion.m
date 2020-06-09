function [ likelihood ] = flowLikelihood_newMotion( LookUp, magn, height, width, step_r )

[H, W] = size(LookUp);
LookUpSum = sum(LookUp);
col = uint64(min(round(magn./step_r+1), W));

likelihood = LookUpSum(col)./H;
likelihood = reshape(likelihood, height, width);    
    
end

