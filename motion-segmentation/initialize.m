function [ rotation_ABC, translation_UVW ] = initialize( dirFrame1, dirFlow1, focallength_px)

rng default
average_pixelError = realmax;

OF = load(dirFlow1);
OF = OF.uv;

[height, width, ~] = size(OF);

xmin = floor(-(width-1)/2);
xmax = floor((width-1)/2);
ymin = floor(-(height-1)/2);
ymax = floor((height-1)/2);
x_comp = repmat(xmin:xmax, height, 1);
y_comp = repmat((ymin:ymax).', 1, width);

%create superpixels
Img = imread(dirFrame1);
regionSize = height*width*0.0001;%20 ;
regularizer = 0.5 ;
segments = vl_slic(im2single(Img), regionSize, regularizer) ;

%outlier threshold
errorThresh = 0.1;

% create bucket matrix (all four corners of the image)
bucket_height = floor(height./5);
bucket_width = floor(width./5);

bucket_topL = segments(1:bucket_height, 1:bucket_width);
bucket_topR = segments(1:bucket_height, (width-bucket_width+1):width);
bucket_bottomL = segments((height-bucket_height+1):height, 1:bucket_width);
bucket_bottomR = segments((height-bucket_height+1):height, (width-bucket_width+1):width);

bucket_matrix = cell(4,1);%zeros(bucket_height, bucket_width, 4);
bucket_matrix(1,1) = {unique(bucket_topL)};
bucket_matrix(2,1) = {unique(bucket_topR)};
bucket_matrix(3,1) = {unique(bucket_bottomL)};
bucket_matrix(4,1) = {unique(bucket_bottomR)};

disp('Initialization...');

clearvars bucket_topL bucket_topR bucket_bottomL bucket_bottomR bucket_width bucket_height regularizer regionSize Img imageformate dirFlow 
tic;    

for loopRANSAC = 1:5000
    
        patch = bucketing( segments, bucket_matrix );
    
        [rotation_ABC_current, translation_UVW_current] = CameraMotion( OF, patch, [0 0 0], focallength_px );
        
        [RotOF] = getRotofOF( rotation_ABC_current, x_comp, y_comp, focallength_px);
        RotadjustedOF_current = OF - RotOF;
        RotadjustedAF_current = anglefield(RotadjustedOF_current);

        % find best fitting translational anglefield to anglefieldTransOF 
        TransOF_ideal(:,:,1) = -translation_UVW_current(1).*focallength_px+x_comp.*translation_UVW_current(3);
        TransOF_ideal(:,:,2) = -translation_UVW_current(2).*focallength_px+y_comp.*translation_UVW_current(3);

        TransAF_ideal_bg_current = anglefield( TransOF_ideal );
        
        dif_current = abs( RotadjustedAF_current - TransAF_ideal_bg_current );
        dif_current = min( dif_current, abs(360-dif_current));
        magn = sqrt(RotadjustedOF_current(:,:,1).^2+RotadjustedOF_current(:,:,2).^2);
        pE_current = pi.*magn.*(dif_current./180);
        
        average_pixelError_current = (pE_current>errorThresh);
        average_pixelError_current =  sum(sum(average_pixelError_current));
            
        if average_pixelError_current < average_pixelError
            rotation_ABC = rotation_ABC_current;
            translation_UVW = translation_UVW_current;
            average_pixelError = average_pixelError_current;
        end
        
        if (mod(loopRANSAC,100) == 0 )
            disp(sprintf('%s%d/%d', 'Iteration ', loopRANSAC, 5000));
        end
        
end

elapsed = toc;

text = sprintf('%s', 'Initialization finished in %gsec\n');
fprintf(text, elapsed);

end

