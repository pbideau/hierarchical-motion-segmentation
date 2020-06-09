function [ TransAngle, dif, invert] = chooseTrans( idx, TransOF_ideal, RotadjustedAF )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %select translational anglefield with smalles difference in Angle
    TransAngle_1 = anglefield(TransOF_ideal);
    TransAngle_2 = mod(TransAngle_1+180, 360);

    dif_1 = abs( RotadjustedAF(idx) - TransAngle_1(idx) );
    dif_1 = min( dif_1, abs(360-dif_1));

    if sum(sum(dif_1)) < numel(dif_1)*90 
        TransAngle = TransAngle_1;
        dif = dif_1;
        invert = 1;
    else     
        TransAngle = TransAngle_2;
        dif = 180-dif_1;
        invert = -1;
    end


end

