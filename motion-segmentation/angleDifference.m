function [Dif_Angle] = angleDifference(anglefieldA, anglefieldB)

    Dif_Angle = anglefieldA - anglefieldB;
    
    case_A = Dif_Angle > 180;
    case_B = Dif_Angle < -180;
    case_C = abs((case_A + case_B) - 1);
    Dif_Angle_groesser180 = (Dif_Angle - 360) .* case_A;
    Dif_Angle_kleinerNeg180 = (Dif_Angle + 360) .* case_B;
    Dif_Angle_kleiner180 = Dif_Angle .* case_C;
    
    Dif_Angle = abs(Dif_Angle_groesser180 + Dif_Angle_kleiner180 + Dif_Angle_kleinerNeg180);
    
end

