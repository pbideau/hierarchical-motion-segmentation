function [ newMotionComp, idx_MotionComp, imbin_probability] = findMotionComp_firstFrame( RotadjustedAF,  TransAF_ideal_bg, RotadjustedOF, OtsusThresh, maxNumMotions, minNumPixels)
    
    exist_idx = 0;
    regionError_current = 0;
    [height, width] = size(RotadjustedAF);
    newComp = zeros(height, width);
    %idx_MotionComp = cell(1,1,maxNumMotions);
    imbin_probability = zeros(height, width);
    tooSmall = ones(height, width);
    zeroMask = zeros(height, width);
    
    % -------------------------------------------------------------------------
    % Segmentation using Otsus method (first frame only)
    % -------------------------------------------------------------------------
    dif = abs( RotadjustedAF - TransAF_ideal_bg );
    dif = min( dif, abs(360-dif));

    magn = sqrt(RotadjustedOF(:,:,1).^2+RotadjustedOF(:,:,2).^2);
    pE = pi.*magn.*(dif./180);

    [thresh, effectiveness] = multithresh(pE, 1);
    imbin = (pE > thresh(1));

    n = 1;

    while (effectiveness > OtsusThresh && n<=maxNumMotions)

        %find region with largest average error
        CC = bwconncomp(imbin);

        for k=1:CC.NumObjects

            PixelList = CC.PixelIdxList{k};
            numPixel = length(PixelList);

            if numPixel > minNumPixels                    
                regionError = sum(pE(PixelList))/numPixel;           
                if regionError > regionError_current
                    regionError_current = regionError;
                    idx = k;
                    exist_idx = 1;
                end                   
            else
                tooSmall(CC.PixelIdxList{k}) = 0;                   
            end

        end

        %make sure that idx exists - component containing more than minNumPixels
        %pixels is found
        if(exist_idx == 1)      
            zeroMask(CC.PixelIdxList{idx}) = 1;
            newComp(CC.PixelIdxList{idx}) = 1;
            %newMotionComp(:,:,n) = newComp;%.*effectiveness;
            %idx_MotionComp(:,:,n) = {[CC.PixelIdxList{idx}]};
            imbin_probability = imbin_probability + newComp;%.*effectiveness;
            imbin = abs(zeroMask-1);
            pE = pE.*imbin;          
        end

        pE = pE.*tooSmall;
        [B, C, ~] = find(1-tooSmall);
        idx_tooSmallTOremove = sub2ind([height, width], B, C);
        clearvars B C wert
        [B, C, ~] = find(zeroMask);
        idx_MotionCompTOremove =  sub2ind([height, width], B, C);
        clearvars B C wert
        PixelList_toRemove = cat(1, idx_tooSmallTOremove, idx_MotionCompTOremove);

        Adif_likelihood_vec = reshape(pE, [height*width, 1]);
        A = zeros(height*width, 2);
        A(:,1) = 1:height*width;
        A(:,2) = Adif_likelihood_vec;
        [A_removedComp, ~] = removerows(A, 'ind',  PixelList_toRemove);

        [thresh, effectiveness] = multithresh( A_removedComp(:,2), 1);
        imbin = (pE > thresh(1));

        newComp = zeros(height, width);
        n = n+1;

        CC = [];
        exist_idx = 0;
        regionError_current = 0;
        clearvars idx
    end
    
    %----------------------------------------------------------------------
    %join motion components that are connected
    %----------------------------------------------------------------------
    CC = bwconncomp(imbin_probability);
    
    idx_MotionComp = cell(length(CC.PixelIdxList), 1);
    for i = 1: length(CC.PixelIdxList)
        idx_MotionComp{i, :} = CC.PixelIdxList{i};
    end
    
    newMotionComp = zeros(height, width,length(CC.PixelIdxList));
    for i = 1:length(CC.PixelIdxList)
        newComp(CC.PixelIdxList{i}) = 1;
        newMotionComp(:,:,i) = newComp;
        newComp = zeros(height, width);
    end
    
    
    if(effectiveness<=OtsusThresh && n==1)
        newMotionComp = zeros(height, width, 1);
    end
    
    imbin_probability = abs(imbin_probability -1);

end

