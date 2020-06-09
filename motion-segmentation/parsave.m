function [  ] = parsave(name, var )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
save(name, '-struct', 'var', '-v7.3');

end

