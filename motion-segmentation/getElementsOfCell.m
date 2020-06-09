function [ list_elements ] = getElementsOfCell( cellArray )
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    [H,W]=size(cellArray);
    list_elements = [];
    for i = 1:H
        for j = 1:W
            list_elements = [list_elements; cellArray{i,j}];
        end
    end
     
end

