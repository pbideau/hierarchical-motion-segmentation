function [ rotation_ABC, translation_UVW] = CameraMotion( OF, mask, RotValue_prev, focallength )
% INPUT: OF             optical flow (heightxwidthx2 matrix)
%        u, v           values of the optical flow OF(:,:,1) and OF(:,:,2), 
%                       which belong to a single motion like background.
%                       Pixels of a moving object for example a car are not
%                       included.
%        row, col       position
%                       Example: pixel position of u is (row,col, 1)
%        mask           binary (heightxwidth)-matrix. 
%                       1 if optical flow at this position belongs
%                       to a single motion like backround otherwise 0.
%        height, width  size of optical flow
%
% OUTPUT: TransAngle    ideal translational anglefield, which discribes
%                       the pure camera motion (motion of the static
%                       background)
%         RotadjustedOF observed translational flow field 
%                       (observed optical flow - ideal rotational flow)          
%         RotadjustedAF anglefield of RotadjustedOF  
%         dif           angledifference between anglefield of RotadjustedOF
%                       TransAngle
%         pE            pseudo projection error

    [x_comp_idx, y_comp_idx] = getPixels( ~mask );

    idx_motionComponent = find(mask);
    uv = OF(cat(3, idx_motionComponent, idx_motionComponent+numel(mask)));
    
    %--------------------------------------------------------------------------
    % gradient decent over rotations
    %--------------------------------------------------------------------------
    f = @(x)fcn_to_minimize(x, uv, x_comp_idx, y_comp_idx, focallength);
    options = optimset('LargeScale','off', 'Display', 'off');
    [rotation_ABC, ~, ~] = fminunc( f, RotValue_prev, options); 

    [RotOF] = getRotofOF( rotation_ABC, x_comp_idx, y_comp_idx, focallength);
    RotadjustedOF = uv - RotOF;
    RotadjustedAF = anglefield(RotadjustedOF);
    
    % find best fitting translational anglefield to anglefieldTransOF 
    translation_UVW = Translation( RotadjustedOF(:,:,1), RotadjustedOF(:,:,2), x_comp_idx, y_comp_idx, focallength);
    TransOF_ideal(:,:,1) = -translation_UVW(1).*focallength+x_comp_idx.*translation_UVW(3);
    TransOF_ideal(:,:,2) = -translation_UVW(2).*focallength+y_comp_idx.*translation_UVW(3);
    
    [~, ~, invert] = chooseTrans( 1:numel(RotadjustedAF), TransOF_ideal, RotadjustedAF );
    translation_UVW = translation_UVW*invert;

end


