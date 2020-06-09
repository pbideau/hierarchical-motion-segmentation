function [ objectProposals_mask, mask_smooth ] = objectProposal( numObjects, motionPosterior, pathSharpmask, frame )

    pathMask = sprintf('%s/frame%03d/', pathSharpmask, frame);
    
    listMask = [dir(fullfile(pathMask, 'bin_mask*'))];
    listMask = extractfield(listMask, 'name')';
    listMask_smooth = [dir(fullfile(pathMask, 'mask*'))];
    listMask_smooth = extractfield(listMask_smooth, 'name')';

    for i = 1:length(listMask)
        listMask{i} = strcat(pathMask,  listMask{i});
        listMask_smooth{i} = strcat(pathMask, listMask_smooth{i});
    end
    
    % get filepaths from csv file
    fileID = fopen(sprintf('%sscores.txt', pathMask)); 
    scores = cell2mat(textscan(fileID,'%f'));

    % read all object proposal masks
    mask = imread(listMask{i});
    [H, W, ~] = size(mask);
    mask = zeros(H, W, length(listMask));
    
    for i = 1:length(listMask)
        mask(:,:,i) = imread(listMask{i});
    end
    
    [objectProposals_mask, idx_objectProposals] = selectObjectProposal(numObjects, mask, scores, motionPosterior);
    
    % read all object proposal masks
    mask_smooth = zeros(H, W, length(idx_objectProposals));
    
    for i = 1:length(idx_objectProposals)
        mask_smooth(:,:,i) = imread(listMask_smooth{idx_objectProposals(i)});
    end
end

