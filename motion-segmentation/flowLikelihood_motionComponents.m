function [ likelihood_fg ] = flowLikelihood_motionComponents( idx_MotionComp, RotadjustedOF, height, width, x_comp, y_comp, RotadjustedAF, LookUpLikelihood, magn_Vec, step_r, step_theta, focallength_px)
% -------------------------------------------------------------------------
% ith component likelihood: 
% based on the rotation adjusted flowfield find the best fitting
% translational motion for the ith motion component. 
% Computation of the likelihood is using the von Mises
% distribution with kappa, which is dependent on the flow magnitude
% -------------------------------------------------------------------------
likelihood_fg = zeros(height, width, length(idx_MotionComp));

for s = 1:length(idx_MotionComp)
        
     idx_MotionComp_i = idx_MotionComp{s,:};

     RotadjustedOF_MotionComp = RotadjustedOF([idx_MotionComp_i; idx_MotionComp_i+height*width]);
     RotadjustedOF_MotionComp = reshape(RotadjustedOF_MotionComp, [length(idx_MotionComp_i) 1 2]);
     
     x = x_comp(idx_MotionComp_i);
     y = y_comp(idx_MotionComp_i);

     % translational motion of ith component
     [ translation_UVW] = Translation( RotadjustedOF_MotionComp(:,:,1), RotadjustedOF_MotionComp(:,:,2), x, y, focallength_px);
     TransOF_ideal = cat(3, -translation_UVW(1).*focallength_px+x_comp.*translation_UVW(3), -translation_UVW(2).*focallength_px+y_comp.*translation_UVW(3));
     [ Angle_MotionComp_ideal, ~] = chooseTrans( idx_MotionComp_i, TransOF_ideal, RotadjustedAF );

     % Computation of the likelihood of ith component
     Dif_Angle_fg = angleDifference(RotadjustedAF, Angle_MotionComp_ideal);
     likelihood_fg( :, :, s) = flowLikelihood( LookUpLikelihood, Dif_Angle_fg, magn_Vec, height, width, step_r, step_theta );

end  


end

