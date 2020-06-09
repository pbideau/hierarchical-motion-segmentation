function [ PseudoPrior ] = Posterior2Prior(Posterior, flow, prevSegmentation)

%starttime = tic; 
[H,W] = size(Posterior);
sD = 1;  % Is this too small?%12
sDtot = sD*2+1;
spatialWeight = fspecial('gaussian', [sDtot sDtot], 1);

Padding=200;
a = 1+Padding;
b = H+Padding;
c = W+Padding;

% The SIZE of X and Y is H by W. However, X and Y index into the PADDED array.
[X,Y] = meshgrid(a:c, a:b);   
gridXY = cat(3, X, Y);
newPos = round(flow+gridXY);   % newPos indexes into PADDED array.
flipNewPos=flip(newPos,3);     % Make y come first.
reshapeNewPos=reshape(flipNewPos,[W*H 2]);
mappedPriors=accumarray(reshapeNewPos,Posterior(:),[H+2*Padding,W+2*Padding]);

%normalize mappedPriors
linearInd = sub2ind([H+2*Padding,W+2*Padding], reshapeNewPos(:,1), reshapeNewPos(:,2));
linearInd_unique = unique(linearInd);
count = [linearInd_unique,histc(linearInd(:),linearInd_unique)];
norm = zeros(H+2*Padding, W+2*Padding);
norm(count(:,1))=count(:,2);
normalizedMappedPriors = mappedPriors./norm;

[ normalizedMappedPriors, wasMoving ] = fillDisocclusionRegions( normalizedMappedPriors, prevSegmentation , H, W, Padding, Posterior, flow);

PseudoPrior=conv2(normalizedMappedPriors,spatialWeight,'same').*wasMoving;

end