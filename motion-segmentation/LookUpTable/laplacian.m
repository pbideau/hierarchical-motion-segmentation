function [ l ] = laplacian( x, mu, sigma )

l = 1/(2*sigma)*exp(-abs(x-mu)/sigma);

end

