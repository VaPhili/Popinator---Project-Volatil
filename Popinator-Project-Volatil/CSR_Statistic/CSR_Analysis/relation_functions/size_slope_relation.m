
% linear highlight function:
% This functions multiplies every value in a given array by a given factor

function out = size_slope_relation(in)
    s = size(in, 1);

    out = zeros(s,2); % size,angle
    out(:,1:2) = in(:,3:4);
end

