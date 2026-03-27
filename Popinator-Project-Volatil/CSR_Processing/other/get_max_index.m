
% get maximum index function:
% returns theindex of the maximum y-value of a table

function out = get_max_index(in, column)
    s = size(in);
    s = s(1);
    mi = 1;
    for i = 1:s
        if in(i,column) > in(mi,column)
            mi = i;
        end
    end
    
    out = mi;
end