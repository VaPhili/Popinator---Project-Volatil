
% expect the values to be in order and valid

function out = get_slope(dat, i1, i2)

    % m = (y2 - y1)/(x2 - x1)
    out = (dat(i2,2) - dat(i1,2))/(dat(i2,1) - dat(i1,1));
end