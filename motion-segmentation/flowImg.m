function [ Img_flowed ] = flowImg( Img, flow )

    [H,W] = size(Img);

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
    mappedPriors=accumarray(reshapeNewPos,Img(:),[H+2*Padding,W+2*Padding]);

    %normalize mappedPriors
    linearInd = sub2ind([H+2*Padding,W+2*Padding], reshapeNewPos(:,1), reshapeNewPos(:,2));
    linearInd_unique = unique(linearInd);
    count = [linearInd_unique,histc(linearInd(:),linearInd_unique)];
    norm = zeros(H+2*Padding, W+2*Padding);
    norm(count(:,1))=count(:,2);
    Img_flowed = mappedPriors./norm;
    
    Img_flowed(Img_flowed~=1)=0;
    Img_flowed = Img_flowed((Padding+1):H+Padding, (Padding+1):W+Padding);
    
end

