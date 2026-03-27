
% get median function:
% returns the median of the y values

function out = get_median(in)
    s = size(in);
    s = s(1);

    tmp = sort(in);
    
    if mod(s,2) == 0
        out = tmp(s/2);
    else
        out = 0.5 * (tmp(floor(s/2)) + tmp(ceil(s/2)));
    end
end