function  [masks_stack, idx_motionProposals] = selectObjectProposal(numObjects, mask, scores, motionPosterior)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    dif = realmax;

    for i=1:1000
        numObjects_rnd = uint8(normrnd(numObjects,0.5));
        scores_cur = scores;
        numProposals = 1:length(scores);
        
        idx = zeros(numObjects_rnd,1);
        idx_cur = zeros(numObjects_rnd,1);
        for n = 1: numObjects_rnd
            
            randNum = rand(1, 1);

            % transform scores
            scores_prob = normpdf(scores_cur,1,0.1);
            norm = 1./(sum(scores_prob));
            scores_norm = scores_prob.*norm;
            scores_cum = cumsum(scores_norm);
            scores_cum = [0; scores_cum];
            scores_mid = zeros(1, numel(scores_cum)-1);
            for j = 1:(numel(scores_cum)-1)
                scores_mid(j) = (scores_cum(j+1)-scores_cum(j))/2 + scores_cum(j);
            end

            % find idx of scores and mask that is picked randomly
            [~, idx_cur(n)] = min(abs(scores_mid-randNum));
            scores_cur(idx_cur(n)) = [];
            
            idx(n) = numProposals(idx_cur(n));
            
            numProposals(idx_cur(n)) = [];
            
        end
        
        objectProposalSmooth = sum(mask(:,:,idx).^2, 3);
        objectProposal = sum((mask(:,:,idx)), 3)/(double(numObjects_rnd)+2);
        A = motionPosterior-objectProposal;
        B = sum(mask(:,:,idx), 3);
        B(B>1)=1;
        
        C = A>0 & B;

        A(C==1)=0;
        dif_cur = sum(sum(abs(A)));
        
        %dif_cur = sum(sum(abs(motionPosterior-objectProposal)));
        
        if dif_cur<dif
            dif=dif_cur;
            dif_img = abs(A);%abs(motionPosterior-objectProposal);
            objectProposals_mask = objectProposalSmooth;
            idx_motionProposals = idx;
            objectProposals_scores = scores(idx_motionProposals);
        end
        
    end
    
    %-----------------------------------------------------------------------
    % remove unnecessary masks and scores (do not decrease dif)
    %-----------------------------------------------------------------------
    idx_temp = idx_motionProposals;
    numObjects = length(idx_temp);
    i=1;
    while i <= length(idx_motionProposals)
        idx_temp(i) = [];

        objectProposalSmooth = sum(mask(:,:,idx_temp).^2, 3);
        objectProposal = sum((mask(:,:,idx_temp)), 3)/(double(numObjects)+2);
        A = motionPosterior-objectProposal;
        B = sum(mask(:,:,idx_temp), 3);
        B(B>1)=1;
        C = A>0 & B;
        A(C==1)=0;
        dif_cur = sum(sum(abs(A)));
        if dif_cur<dif
            
            i = i-1;
            dif=dif_cur;
            dif_img = abs(A);
            idx_motionProposals = idx_temp;
            objectProposals_mask = objectProposalSmooth;
            objectProposals_scores = scores(idx_motionProposals);
            objectProposalSmooth = sum(mask(:,:,idx_motionProposals).^2, 3);
            
        end
        idx_temp = idx_motionProposals;
        i = i+1;
    end
    
    masks_stack = mask(:,:,idx_motionProposals);
end

