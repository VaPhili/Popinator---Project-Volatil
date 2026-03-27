
% get maximum index closest to a given value function:

function out = get_closest_index(in, column, val)
    s = size(in,1);

    mi = 1;
    set = false;
    for i = 2:s
        if in(i,column) > val && set == false
            set = true;
            mi = i-1;
        end
    end
    
    out = mi;
end