function [ patch ] = bucketing( segments, bucket_matrix )
%BUCKETING Summary of this function goes here
%   Detailed explanation goes here

random_bucket = randperm(4,3);
selected_bucketingMatrix = bucket_matrix(random_bucket,1);
L = cellfun('length', selected_bucketingMatrix);

% select three patches of the four corner buckets
r = zeros(3,1);
for bucket_num = 1:3   
    r(bucket_num) = randperm(L(bucket_num),1);
    r(bucket_num) = selected_bucketingMatrix{bucket_num,1}(r(bucket_num),1);  
end

patch = ismember(segments, r);

% select seven patches randomly
mask = uint32((patch.*2 - 1).*(-1));
segments = segments.*mask;
C = unique(segments(segments>0));

r = randperm(length(C),7);
r = C(r);

patch = patch + ismember(segments, r);

end

