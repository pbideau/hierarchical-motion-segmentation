function [idx ] = similarity2objects( objects2labels_frame, objects2labels_prev )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
a= length(objects2labels_frame);
b=length(objects2labels_prev);
similarity_rank = zeros(a, b);

for i = 1:a %current frame
    for j = 1:b %prev frame
         similarity = sum(ismember(objects2labels_frame{i, 1}, objects2labels_prev{j, 1}));
         similarity_rank(i,j) = similarity;
    end
end

% Invert matrix since munkres searches for the minimal cost
max_value               = max(max(similarity_rank));
similarity_rank_inv  = max_value - similarity_rank;

% Find linear assignment
[assignment, ~] = munkres(similarity_rank_inv);

% if there was no assignment use zero
for i = 1:size(similarity_rank,1)
    %{
    if sum(similarity_rank(i,:)) == 0
        assignment(i) = 0;
    end
    %}
    if assignment(i)~=0
        if similarity_rank(i, assignment(i))==0
            assignment(i) = 0;
        end
    end
end

% idx of object2labels_prev that are assigned to a frames object
idx = assignment;

end

