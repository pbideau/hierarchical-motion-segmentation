function [ bin_flowed ] = flowingBin( bin, OF )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[num_row, num_col] = size(bin);
bin_flowed = zeros(size(bin));

idx = find(bin);
[row, col] = ind2sub([num_row num_col],idx);

u = OF(idx);
v = OF(idx+num_row*num_col);
        
row_newPos = round(row+v);
col_newPos = round(col+u);

for i = 1:length(row)
    if (row_newPos(i) > 0 && row_newPos(i) <= num_row && col_newPos(i) > 0 && col_newPos(i) <= num_col)
        bin_flowed(row_newPos(i), col_newPos(i)) = 1;
    end
end


end

