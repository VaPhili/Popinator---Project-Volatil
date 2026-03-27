
% advanced width detection function:
% for a given set of indent position this function tries to detect the
% width of the given indent. treshold determines the sensitivity of this
% method

function out = get_slope_samples(dat, i)

    % m = (y2 - y1)/(x2 - x1)
    % samples are tuples of two index shifts
    %samples = [0,1; 0,2; 0,4; -1,0; -2,0; -4,0; -1,1; -2,2; -3,3];
    samples = [0,1; 0,2; -1,0; -2,0; -1,1; -2,2];
    samples = samples + i;
    n = size(samples,1);
    slopes = zeros(n,1);

    for s = 1:n
        if(samples(s,1) >= 1 && samples(s,1) <= size(dat,1) && samples(s,2) >= 1 && samples(s,2) <= size(dat,1))
            slopes(s,1) = get_slope(dat,samples(s,1), samples(s,2));
        else
            n = n-1;
        end
    end

    out = slopes;
end