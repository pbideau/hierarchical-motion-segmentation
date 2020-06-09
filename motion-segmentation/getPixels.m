function [ x_comp_idx, y_comp_idx ] = getPixels( segmentation )

    [height, width] = size(segmentation);
    idx_motionComponent = find(~segmentation);

    x_shift = width/2;
    y_shift = height/2;

    xM = repmat( 0:(width-1), height, 1);
    yM = repmat( [0:(height-1)].', 1, width);
    x = xM-x_shift;
    y = yM-y_shift;

    x_comp_idx = x(idx_motionComponent);
    y_comp_idx = y(idx_motionComponent);

end
