function [ likelihood ] = flowLikelihood( LookUp, Dif_Angle, magn, height, width, step_r, step_theta )

Dif_Angle_Vec = reshape(Dif_Angle, 1, height*width);

[H, W] = size(LookUp);
row = min(round(Dif_Angle_Vec./step_theta+1),H)';
col = min(round(magn./step_r+1), W);

idx = uint64((col-1)*H+row);

likelihood = LookUp(idx);
likelihood = reshape(likelihood, height, width);

end

