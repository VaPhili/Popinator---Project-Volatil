
% get minimum value function:
% returns the maximum y-value of a table

function out = get_min_value(in, columns)
    s = size(in);
    s = s(1);
    out = 100000000000000000000;
    for i = 1:s
        sum = 0;
        for s = columns
            sum = sum + in(i,s);
        end
        if sum < out
            out = sum;
        end
    end
end