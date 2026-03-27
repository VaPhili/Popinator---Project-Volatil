
% get maximum value function:
% returns the maximum y-value of a table

function out = get_max_value(in, columns)

    out = 0;
    for i = 1:size(in,1)
        sum = 0;
        for s = columns
            sum = sum + in(i,s);
        end
        if sum > out
            out = sum;
        end
    end
end