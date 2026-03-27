


function position_statistic(data,path,segments)


    % TODO REWORK; CURRENTLY NOT IN USE


    % x: position, y:amount, ver:type(Anlassstufe), hor:[rate],material , col: num(same col), rate
    
    datasets = size(data,1);
    % data is a cell array with each column being a 1x6 cell with metadata
    % and a (nx1)x4 cell of popin events according to the filetype
    % data{i,1} = {metatype metarate metanum metamethod metadate metamaterial};
    % data[i,2} = popins: X - Y - Width - Angle

    tmp = data(:,1);
    metadata = vertcat(tmp{:});
    tmp = metadata(:,1);
    types = unique(tmp);
    %tmp = metadata(:,2);
    rates = {0.1, 0.25, 1, 2, 3, 4, 5, 6, 7, 8 ,9, 10}; %unique(tmp); %KA warum er das nicht will

    colors = ["#0072BD", "#D95319", "#EDB120", "#7E2F8E", "#77AC30", "#4DBEEE", ...
        "#A2142F", "#FF00FF", "#FF0000", "#00FF00", "#000000", "#0000FF"];

    maxval_x = 0;
    %maxval_y
    for d = 1:datasets
        for i = 1:size(data{d,2},1)
            if data{d,2}(i,1) > maxval_x
                maxval_x = data{d,2}(i,1);
            end
        end
    end
    segmentsize = maxval_x / segments;

    % calculate the segment entries
    segmentation = zeros(datasets,segments+1);
    for d = 1:datasets
        for i = 1:size(data{d,2})
            % for each entry, add 1 to the respective field in segmentation
            val_x = data{d,2}(i,1);
            seg = round( val_x/maxval_x *segments ) +1;
            segmentation(d,seg) = segmentation(d,seg) +1;
        end
    end
    segmentation_axis = zeros(segments+1,1);
    for i = 0:segments
        segmentation_axis(i+1) = segmentsize * i + segmentsize*0.5;
    end

    % sort for average and error
    sorted = cells(segments+1, size(rates,2), size(types,1));
    for type = 1:size(types,1)
        for rate = 1:size(rates,2)
            for dat = 1:datasets
                for seg = 1:segments+1
                    if (data{i,1}{1,1} == types{type} & data{i,1}{1,2} == rates{rate})

                        sorted{seg,rate,type}(end+1) = segmentation(dat,seg);

                    end
                end
            end
        end
    end

    % Plot each cast_type
    plots = [];
    t = tiledlayout(1,5);

    for type = 1:size(types,1)

        plots(end+1) = nexttile;
        hold on;

        for rate = 1:size(rates,2)
            
            tmp = [];
            index = [];
            for i = 1:datasets
                if (data{i,1}{1,1} == types{type} & data{i,1}{1,2} == rates{rate})
                    tmp(end+1,:) = segmentation(i,:);
                    index(end+1) = i;
                    

                    % Write to file
                    %fprintf(fid,'%f\n',1); complicated to write since
                    %there are more than 2 relevant dimensions
                end
            end

            for i = 1:size(tmp,1)
                scat = scatter(segmentation_axis(:,1),tmp(i,:));
                scat.MarkerEdgeColor = colors(rate);
            end
        end
        hold off;
    end

    % Export the data


end