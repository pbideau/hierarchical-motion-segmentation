function [ ] = createOverlayVideo_4panel(dirFrames, SegmentationCell, TransIdealCell, TransCell, dirVideo)
% INPUT: SegmentationCell segmentations (numx1 cell array)     
%        firstidxOF       number of first frame (mostly 1)    
%        lastidxOF        number of last frame-1 
%        video            video name, for example 'forest'
%        imageformate     formate of the frame, for example '.png'
%        dirVideo         directory where video will be saved

%fnameFormat = '%s/%s%03d%s';
%prefix_Error = [video, '_'];
%dirImg = sprintf('../%s/%s_%s/%s', 'data', dataset, video, 'frames');
%fileExt = imageformate;

colorList = zeros(15,3);
colorList(1,:) = [0.486, 0.906, 0];
colorList(2,:) = [0.031, 0.424, 0.635];
colorList(3,:) = [1, 0.545 , 0];
colorList(4,:) = [0.863, 0 , 0.333];
colorList(5,:) = [1, 0.988 , 0];
colorList(6,:) = [0, 0.616 , 0.568];
colorList(7,:) = [0.423, 0.039 , 0.670];
colorList(8,:) = [0.403, 0.619 , 0.823];
colorList(9,:) = [0.568, 0 , 0.2];
colorList(10,:) = [0.294, 0.584 , 0];
colorList(11,:) = [0.937, 0.423 , 0.604];
colorList(12,:) = [1, 0.9 , 0];
colorList(13,:) = [1, 0 , 0];

%videoname  = sprintf('%s_rndStartSGD_%03d.%s', video, focallength_sensorwidth,  'avi');
outputVideo = VideoWriter(fullfile(dirVideo, 'video.avi'));
outputVideo.FrameRate = 15;
open(outputVideo);
numFrames = length(dirFrames)-1;

alpha = 0.3;

%find number of motion components
val = [];
for i = 1:(numFrames)
    segmentationOrig = cell2mat(SegmentationCell(i,2));
    val_cur = unique(segmentationOrig);
    for n = 1:length(val_cur)
        if ~any(val == val_cur(n))
            val(length(val)+1) = val_cur(n);
        end
    end    
end


for i = 1:numFrames
    
    origImg = imread(dirFrames{i});

    segmentationOrig = cell2mat(SegmentationCell(i,2));

    [height, width, ~] = size(origImg);
    
    segmentation = zeros(height, width);

    mask = zeros(height, width, 3, length(val));
    for t=1: length(val)
        segmentation(segmentationOrig==val(t))=1;
        segmentation = im2double(segmentation);
        %create red mask
        mask(:,:,1,t) = segmentation .* colorList(mod(t,13)+1,1);
        mask(:,:,2,t) = segmentation .* colorList(mod(t,13)+1,2); 
        mask(:,:,3,t) = segmentation .* colorList(mod(t,13)+1,3); 

        segmentation = zeros(height, width);
    end
    
    mask = sum(mask,4); 
    
    %create red mask
    %mask(:,:,1) = segmentation ;
    %mask(:,:,2) = segmentation .* 0.01;
    %mask(:,:,3) = segmentation .* 0.01;

    Img(:,:,1) = rgb2gray(origImg);
    Img(:,:,2) = rgb2gray(origImg);
    Img(:,:,3) = rgb2gray(origImg);

    %create overlay
    overlay = im2double(Img);

    for n = 1 : width
        for m = 1:height

            if (mask(m,n,1)>=0 && mask(m,n,2)>=0  && mask(m,n,3)>=0)
            
                overlay(m,n,1) = alpha .* overlay(m,n,1) + (1 - alpha) .* mask(m,n,1);
                overlay(m,n,2) = alpha .* overlay(m,n,2) + (1 - alpha) .* mask(m,n,2);
                overlay(m,n,3) = alpha .* overlay(m,n,3) + (1 - alpha) .* mask(m,n,3);

            end
        end
    end
    
    % make an RGB image that mathes display from IMAGESC:
    C = hsv(255);
    % scale the matrix to the range of the map
    TransAF_ideal_bg = round((cell2mat(TransIdealCell(i,1))+1).*(255/361));
    TransAF_ideal_bg = reshape(C(TransAF_ideal_bg, :), [size(TransAF_ideal_bg) 3]);
    
    RotadjustedAF = round((cell2mat(TransCell(i,1))+1).*(255/361));
    RotadjustedAF = reshape(C(RotadjustedAF, :), [size(RotadjustedAF) 3]);
    
    origImg = insertText(origImg, [1 20], 'original video','FontSize', 28, 'BoxColor', 'black', 'BoxOpacity', 0.6, 'TextColor', 'white');
    overlay = insertText(overlay, [1 20], 'our Method','FontSize', 28, 'BoxColor', 'black', 'BoxOpacity', 0.6, 'TextColor', 'white');
    TransAF_ideal_bg = insertText(TransAF_ideal_bg, [1 20], 'angle field (translational camera motion)','FontSize', 28, 'BoxColor', 'black', 'BoxOpacity', 0.6, 'TextColor', 'white');
    RotadjustedAF = insertText(RotadjustedAF, [1 20], 'observed angle field (rotation compensated)','FontSize', 28, 'BoxColor', 'black', 'BoxOpacity', 0.6, 'TextColor', 'white');

    frame = [im2uint8(origImg) im2uint8(overlay); im2uint8(TransAF_ideal_bg) im2uint8(RotadjustedAF)];%; im2uint8(AngelDif) im2uint8(Magn)];
    writeVideo(outputVideo, frame);

    
end

close(outputVideo);

end

