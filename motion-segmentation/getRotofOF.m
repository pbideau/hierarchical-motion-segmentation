function [ RotofOF ] = getRotofOF( rotAngel, x, y, f )

%f=5*imagesize(2)/6.16; %519.48; %focal length in pixel = (f in [mm]) * (imagewidth in pixel) / (CCD width in mm)
%f=6*imagesize(2)/7.6; %1010.53; %focal length in pixel = (f in [mm]) * (imagewidth in pixel) / (CCD width in mm)

RotofOF(:,:,1) = (rotAngel(1)/f) .* x .* y - (rotAngel(2)/f)*(x.^2+f^2) + rotAngel(3).*y;
RotofOF(:,:,2) = (rotAngel(1)/f)*(y.^2+f^2) - (rotAngel(2)/f).*x.*y - rotAngel(3).*x;

end

