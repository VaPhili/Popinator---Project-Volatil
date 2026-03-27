
% returns the avg, min and max density along the function

function out = get_global_density_distribution(in, range)
    s = size(in,1);
    out(s,1) = zeros;

    for i = 1:s
        out(i,1) = get_local_density(in, in(i,1), range);
    end
end