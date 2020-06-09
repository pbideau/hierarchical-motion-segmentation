function [ flow_trans ] = getRotofOF3D( rotationVector, x, y, focallength, flow)

     % -----------------------------------------------------------------
     % move points (camera coordninate system) in 3D and generate optical flow
     % -----------------------------------------------------------------
     x_next = x(:) + reshape(flow(:,:,1), [numel(flow(:,:,1)), 1]);
     y_next = y(:) + reshape(flow(:,:,2), [numel(flow(:,:,2)), 1]);

     % frame t: 3D points in camera coordinate system
     Z = ones(size(x_next));
     X = x_next.*Z./focallength;
     Y = y_next.*Z./focallength;
     points_3D(1,:) = X(:);
     points_3D(2,:) = Y(:);
     points_3D(3,:) = Z(:);

     % frame t+1: move 3D points (camera coordinate system) according to camera motion
     R_x = [1 0 0; 0 cos(rotationVector(1)) -sin(rotationVector(1)); 0 sin(rotationVector(1)) cos(rotationVector(1))];
     R_z = [cos(rotationVector(2)) 0 sin(rotationVector(2)); 0 1 0; -sin(rotationVector(2)) 0 cos(rotationVector(2))];
     R_y = [cos(rotationVector(3)) -sin(rotationVector(3)) 0; sin(rotationVector(3)) cos(rotationVector(3)) 0; 0 0 1];
     rotationMatrix = R_y * R_z * R_x;%R_x * R_y * R_z;

     X_trans = inv(rotationMatrix) * points_3D(1:3,:);

     % frame t+0.5: project points back to 2D
     x_trans =  X_trans .* focallength./repmat(X_trans(3,:), 3, 1);

     % generate translation only optical flow
     flow_trans(:,1) = x_trans(1,:).' - x(:);
     flow_trans(:,2) = x_trans(2,:).' - y(:);
     flow_trans = reshape(flow_trans, size(flow));

end
