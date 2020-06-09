function [  ] = computeLookUpTable(  )

    pV = lookUpV;
    pM = lookUpM;
    
    LookUpTable = pV.*pM;
    LookUpTable = sum(LookUpTable,3);
    save('LookUpTable.mat', 'LookUpTable');
    
end

