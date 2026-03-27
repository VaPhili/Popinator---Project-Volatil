
function out = get_gradient(in)

    s = size(in,1);
    out(s,2) = zeros;
    
    for i = 1:s-1
        % out = in dy / in dx
        out(i,1) = in(i,1);
        out(i,2) = ( in(i+1, 2) - in(i, 2) ) / ( in(i+1, 1) - in(i, 1) );
    end
    out(end,1) = in(end,1);
    out(end,2) = out(end-1,2);
end