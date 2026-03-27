
% using the popindata, this function combines overlapping popins

function pdata = overlap_filter(pdata, scan_data)
    prevs = size(pdata,1); % for printout later

    removal_mask = pdata(:,1) == -1; % All false

    for i = size(pdata,1)-1:-1:1 % []
        for j = i+1:size(pdata,1) % ()
            if removal_mask(j)
                continue
            end
            
            % Case: [ ( ] ) or [ ( ) ] or ( [ ] )
            if is_within(l_width_pos(i,pdata),r_width_pos(i,pdata),l_width_pos(j,pdata),r_width_pos(j,pdata))
                removal_mask(j) = true;
                idx = j;
                if scan_data(pdata(i,1),2) <= scan_data(pdata(j,1),2) 
                    idx = i;
                end
                pdata(i,1:3) = pdata(idx,1:3);
                pdata(i,4) = pdata(idx,2) - min( l_width_pos(i,pdata) , l_width_pos(j,pdata) );
                pdata(i,5) = max( r_width_pos(i,pdata) , r_width_pos(j,pdata) ) - pdata(idx,2);
                pdata(i,6) = pdata(idx,6);
                pdata(i,7) = (pdata(i,7) + pdata(j,7)) / 2;
            end

        end
    end

    pdata(removal_mask,:) = [];

    fprintf("Merged %d into %d popins in overlap filter\n",prevs, size(pdata,1))
end


function out = l_width_pos(idx, data)
    out = data(idx,2) - data(idx,4);
end


function out = r_width_pos(idx, data)
    out = data(idx,2) + data(idx,5);
end


function is = is_within(li, ri, lj, rj)
    is = lj < ri;
end
