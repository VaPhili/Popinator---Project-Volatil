
% linear highlight function:
% This functions multiplies every value in a given array by a given factor

function out = slope_position_relation(in)
    s = size(in, 1);

    out = zeros(s,3); % angle,x,y
    out(:,1) = in(:,4);
    out(:,2:3) = in(:,1:2);
end

