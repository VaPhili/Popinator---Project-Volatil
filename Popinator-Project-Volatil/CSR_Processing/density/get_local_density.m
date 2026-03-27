
% get average function:
% returns the amount of data points in proximity of the xvalue at on the
% data in divided by the total amount of data points. at is not an index!!

function out = get_local_density(in, at, range)
    s = size(in,1);
    
    out = 0;

    for i = 1:s
        if in(i,1) >= at-range && in(i,1) <= at+range
            out = out+1;
        end
    end

    out = out / s;
end