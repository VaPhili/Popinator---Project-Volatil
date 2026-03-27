
% provides a dataset and a list of indices, all indices are removed that
% are no local minima.

function out = minima_filter(idx, dat)
    
    s = size(idx,2);
    out = zeros(s,1);
    outi = 1;

    for i = 1:s
        if     dat(idx(i),2) <  dat( max( idx(i)-1 ,1 ) ,2) % L
            if dat(idx(i),2) <= dat( min( idx(i)+1 ,size(dat,1) ) ,2) % R
                out(outi) = idx(i);
                outi = outi+1;
            end
        end
    end
    out = out(1:outi-1,1);

    fprintf("Filtered %d out of %d values in maxima filter\n",size(out,1), size(idx,2))
end