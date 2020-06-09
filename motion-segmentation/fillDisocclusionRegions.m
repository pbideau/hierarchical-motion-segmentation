function [ Prior, wasMoving ] = fillDisocclusionRegions( disocclusionPrior, prevSegmentation, H, W, Padding, Posterior, flow )
    %UNTITLED7 Summary of this function goes here
    %   Detailed explanation goes here
    
    a = ones(H,W);
    disocclusionPrior = disocclusionPrior((Padding+1):(H+Padding),(Padding+1):(W+Padding));
    a(isnan(disocclusionPrior))=0;

    wasMoving = (a==0 & prevSegmentation==0);
    wasMoving = abs(wasMoving-1);
    
    Prior = inpaint_nans(disocclusionPrior,5);
    %{
    x=1:(H*W);
    y=reshape(disocclusionPrior, [H*W 1]);
    xi=x(find(~isnan(y))); yi=y(find(~isnan(y)));
    try
    if numel(xi)>=2
        disocclusionInterpolated=interp1(xi,yi,x,'linear');
        disocclusionInterpolated = reshape(disocclusionInterpolated,[H W]);
        Prior = disocclusionInterpolated;
    else
       disocclusionPrior(isnan(disocclusionPrior)) = 0;
       Prior = disocclusionPrior;
    end
    catch
       fprintf('num xi: %d\n', numel(xi));  
       fprintf('num yi: %d\n', numel(yi)); 
       fprintf('num x: %d\n', numel(x)); 
       
       save disoccusionPrior.mat
       
        disocclusionInterpolated=interp1(xi,yi,x,'linear');
        disocclusionInterpolated = reshape(disocclusionInterpolated,[H W]);
        Prior = disocclusionInterpolated;
    end
%}
end

