function [ sum_Error ] = fcn_to_minimize( RotVec, uv, x, y, f)

RotOF = getRotofOF( RotVec, x, y, f);
TransOF(:,:,1) = uv(:,:,1) - RotOF(:,:,1);
TransOF(:,:,2) = uv(:,:,2) - RotOF(:,:,2);
magn = sqrt(TransOF(:,:,1).^2+TransOF(:,:,2).^2);
RotadjustedAF = anglefield( TransOF);

%--------------------------------------------------------------------------
%translational component (Berthold Horn, Robot Vision, p.409)
%--------------------------------------------------------------------------
translation_UVW = Translation(TransOF(:,:,1), TransOF(:,:,2), x, y, f);
TransOFideal(:,:,1) = -translation_UVW(1).*f+x.*translation_UVW(3);
TransOFideal(:,:,2) = -translation_UVW(2).*f+y.*translation_UVW(3);

[~, dif] = chooseTrans(1:numel(RotadjustedAF), TransOFideal, RotadjustedAF);

%--------------------------------------------------------------------------
%projection Error
%--------------------------------------------------------------------------
pError = pi.*magn.*(dif./180);
sum_Error = sum(sum(pError))/numel(pError);

end

