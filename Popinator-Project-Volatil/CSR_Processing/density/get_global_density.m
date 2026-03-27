
% returns the avg, min and max density along the function

function [average,minimum,maximum] = get_global_density(in, range)
    s = size(in,1);
    
    average = 0;
    minimum = 10000000000;
    maximum = 0;

    for i = 1:s
        tmp = get_local_density(in, in(i,1), range);

        average = average + (tmp / s);
        minimum = min([tmp, minimum]);
        maximum = max([tmp, maximum]);
    end

end