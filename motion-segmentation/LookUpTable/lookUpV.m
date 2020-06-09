function [ pV ] = lookUpV( A )

%angle difference between ideal flow and observed flow
angleDif = [0:0.1:180]';
aDifSize = numel(angleDif);

%magnitude of the ideal flow
m = 0:0.07:25;
mSize = numel(m);

%magnitude of the observed flow (rotation adjusted)
v = 0:0.07:25;
vSize = numel(v);
v = repmat(v, aDifSize, 1, mSize);

pV = zeros(aDifSize, vSize, mSize);

m = reshape(m, 1, 1, mSize);
m = repmat(m, aDifSize, vSize);

h = sind(angleDif);
u = cosd(angleDif);
u = repmat(u, 1, vSize, mSize).*v;
h = repmat(h, 1, vSize, mSize).*v;
o = m -u;

for i=1:mSize
    oLength_i = o(:,:,i);
    hLength_i = h(:,:,i);
    
    dist(:,1) = reshape(oLength_i, vSize*aDifSize, 1);
    dist(:,2) = reshape(hLength_i, vSize*aDifSize, 1);
    
    % variance as a function different (true) flow magnitudes
    var_u = A.*139.7.*exp(0.04174.*m(1,1,i));
    var_v = A.*56.65.*exp(0.04881.*m(1,1,i));
    sigma_u = sqrt(var_u/2);
    sigma_v = sqrt(var_v/2);
    
    noise_u = laplacian( dist(:,1), 0, sigma_u);
    noise_v = laplacian( dist(:,2), 0, sigma_v);
    
    noise = noise_u .* noise_v;
    pV(:,:,i) = reshape(noise, aDifSize, vSize);
end

end

