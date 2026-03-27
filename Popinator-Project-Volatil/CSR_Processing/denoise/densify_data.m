
% increases data density in areas which are too sparse by adding additional
% datapoints via linear interpolation. Target density is given in the
% maximal distance between 2 datapoints on the x axis

function out = densify_data(data, target_density)
    i = 2;

    while i < size(data,1)
        d = data(i,1) - data(i-1,1);
        if d > target_density
            extrapoints = ceil(d/target_density);

            interpolatefrom_x = data(i-1,1);
            interpolatefrom_y = data(i-1,2);
            interpolateto_x = data(i,1);
            interpolateto_y = data(i,2);
            
            for ep = 1:extrapoints
                data(i+1:end+1,1:2) = data(i:end,1:2);
                data(i,1) = interpolatefrom_x + (interpolateto_x - interpolatefrom_x)* (ep/(extrapoints+1));
                data(i,2) = interpolatefrom_y + (interpolateto_y - interpolatefrom_y)* (ep/(extrapoints+1));
            end

            i = i+extrapoints;
        end
        i = i+1;
    end

    out(:,:) = data(:,:);
end