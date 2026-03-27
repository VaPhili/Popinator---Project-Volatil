
% get average function:
% returns the average value in a given column

function out = get_average_value(in, columns)
    s = size(in);
    s = s(1);

    out = 0;

    for i = 1:s
        for c = columns
            out = out + in(i,c);
        end
    end

    out = out / s;
end