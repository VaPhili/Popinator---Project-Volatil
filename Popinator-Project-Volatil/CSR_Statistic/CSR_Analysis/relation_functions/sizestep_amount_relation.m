
% linear highlight function:
% This functions multiplies every value in a given array by a given factor

function out = sizestep_amount_relation(in, stepsize)
    s = size(in, 1);

    min = get_min_value(in,3);
    min = floor(min/stepsize) * stepsize;
    max = get_max_value(in,3);
    max = ceil(max/stepsize) * stepsize;

    out = zeros(ceil((max-min)/stepsize), 2); % (Sizeclass, amount);
    for i = 1:size(out,1)
        out(i,1) = min + stepsize*(i-1);
    end

    for i = 1:s
        tmp = floor((in(i,3) - min)/stepsize)+1;
        out(tmp,2) = out(tmp,2)+1;
    end
end

