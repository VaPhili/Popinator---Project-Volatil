% tries finding the interval with the highest density in order to smooth
% that interval exclusively

function [from,to] = get_densest_interval(in,comparison_range,treshold_factor)

    % setup necessary values
    s = size(in,1);   
    density = get_global_density_distribution(in,comparison_range);
    maximum = get_max_value(density,1);
    minimum = get_min_value(density,1);
    treshold = (maximum+minimum)*treshold_factor; % factor should be around 0.6
    index = get_max_index(density,1);

    % left border
    tmp = index;
    while(density(tmp) > treshold && tmp > 1)
        tmp = tmp - 1;
    end
    from = tmp;

    % right border, changed by 1 by default to avoid infinite loops
    tmp = index+1;
    while(density(tmp) > treshold && tmp < s)
        tmp = tmp + 1;
    end
    to = tmp;
end