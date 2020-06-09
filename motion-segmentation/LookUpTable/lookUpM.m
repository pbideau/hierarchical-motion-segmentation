function [ magnSetGauss ] = lookUpM(B)
%magnSetGauss: probability of a flow vectro of length 0:0.07:25

angleDif = [0:0.1:180]';
aDifSize = numel(angleDif);

v = 0:0.07:25;
vSize = numel(v);

mu = 0;
SIGMAflow = B;

magnSetGauss = 2*laplacian( v', mu, SIGMAflow);

magnSetGauss = reshape(magnSetGauss, 1, 1, vSize);
magnSetGauss = repmat(magnSetGauss, aDifSize, vSize, 1);

end

