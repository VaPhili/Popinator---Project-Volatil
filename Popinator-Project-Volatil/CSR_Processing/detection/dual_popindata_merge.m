

function popin_data = dual_popindata_merge(raw, low, up, median, median_gradient, combined_gradient, distance, idx_median, idx_dist, idx_combined, treshold, min_evaluation)

    median_data = process_popin_data(median_gradient, idx_median, median, raw, treshold);
    %distance_data = process_popin_data(distance, idx_dist, median, raw, treshold);
    %combined_data = process_popin_data(combined_gradient, idx_combined, median, raw, treshold);
    % IDX, X ,Y, LW, RW, GRAD, EVAL

    % Filter bad popins
    evaluation_filter_factor = min_evaluation;
    median_data(median_data(:,7) < evaluation_filter_factor,:) = [];
    %distance_data(distance_data(:,7) < evaluation_filter_factor,:) = [];
    %combined_data(combined_data(:,7) < evaluation_filter_factor,:) = [];


    % MERGE POPINS
    % popin_data(size(distance_data,1) + size(median_data,1) + size(combined_data,1),7) = zeros;
    % popin_data(1:size(median_data,1),:) = median_data;
    % popin_data(size(median_data,1)+1:size(median_data,1)+size(distance_data,1),:) = distance_data;
    % popin_data(size(median_data,1)+size(distance_data,1)+1:end,:) = combined_data;
    % popin_data = sortrows(popin_data,1);

    
    median_data = overlap_filter(median_data,median_gradient);

    % Re-Filter
    median_data(median_data(:,7) < evaluation_filter_factor,:) = [];

    % Remove duplicates
    %popin_data = merge_duplicates(popin_data);
    %popin_data = merge_neighbours(popin_data,1);


    scatter(raw(:,1),raw(:,2),10,'.')
    hold on
    plot(low(:,1),low(:,2))
    plot(up(:,1),up(:,2))
    plot(median(:,1),median(:,2))

    stem(median_gradient(:,1),median_gradient(:,2)*4);
    %stem(distance(:,1),distance(:,2)*12);
    %stem(combined_gradient(:,1),combined_gradient(:,2));

    stem(median_data(:,2),median_data(:,3));
    stem(median_data(:,2),median_data(:,7) * -100,'x');

    errorbar(median_data(:,2),median_data(:,3),median_data(:,4),median_data(:,5),'horizontal','LineStyle','none','CapSize',20)

    %stem(distance_data(:,2),distance_data(:,3));
    %stem(distance_data(:,2),distance_data(:,7) * -100,'x');

    %stem(combined_data(:,2),combined_data(:,3));
    %stem(combined_data(:,2),combined_data(:,7) * -100,'x');

    %stem(popin_data(:,2),popin_data(:,3));
    %stem(popin_data(:,2),popin_data(:,7) * -100, 'x');

    %errorbar(popin_data(:,2),popin_data(:,3),popin_data(:,4),popin_data(:,5),'horizontal','LineStyle','none','CapSize',20)
    legend()
    hold off
    

    % Filter overlaps
    % ...

    % TEMPORÄR BIS DISTANTDATEN VERWENDET:
    popin_data = median_data;
    
end

function data = process_popin_data(scan_data,idx,reference_data,raw_data, treshold)
    data(size(idx,1),7) = zeros;
    failtolerance = 3;

    for i = 1:size(idx,1)
        data(i,1) = idx(i,1); 
        data(i,2:3) = reference_data(idx(i,1),1:2);


        % Indices
        refi = idx(i);
        rawi = 1;
        for r = 1:size(raw_data,1)
            if abs(raw_data(r,2)-reference_data(refi,2)) < abs(raw_data(rawi,2)-reference_data(refi,2))
                rawi = r;
            end
        end

        % Slope
        ratio = 1.0; % of reference data
        slope_sample_raw = mean(get_slope_samples(raw_data,rawi));
        slope_sample_ref = min(get_slope_samples(reference_data,refi));
        slope = (slope_sample_ref*ratio+slope_sample_raw*(1-ratio));
        data(i,6) = slope;

        if slope <= 0.001
            slope = 0.001;
        end

        % TODO: SLOPE DOES NOT WORK ON LAST POPIN Vit105_368_SR0p6_00009

        % Width
        stepsize = reference_data(2,1) - reference_data(1,1);
        
        data(i,4) = calculate_popin_width_left(data(i,1), reference_data, stepsize, slope, treshold, failtolerance);
        data(i,5) = calculate_popin_width_right(data(i,1), reference_data, stepsize, slope, treshold, failtolerance);



        % Debug plot
        % linear_x = -5 : 0.1 : +5;
        % linear_y = reference_data(refi,2) + linear_x * slope;
        % linear_x = linear_x + reference_data(refi,1);
        % 
        % scatter(raw_data(:,1),raw_data(:,2),'.')
        % hold on
        % plot(reference_data(:,1),reference_data(:,2))
        % stem(reference_data(refi,1),reference_data(refi,2))
        % plot(linear_x, linear_y);
        % errorbar(data(i,2),data(i,3),data(i,4),data(i,5),'horizontal','LineStyle','none','CapSize',20)
        % legend()
        % hold off
    end

    % Evaluation
    [evaluation, total_weight] = evaluate_popins(data, scan_data, reference_data, treshold, failtolerance);
    data(:,7) = sum(evaluation,2) ./ total_weight;
end






function data = merge_duplicates(data)
    for i = 1:size(data,1)
        if(i > size(data,1))
            break; % Weil: Löschen von elementen
        end
        mask = data(:,1) == data(i,1);
        matches = sum(mask);
        data(i,4) = mean(data(mask,4));
        data(i,5) = mean(data(mask,5));
        data(i,6) = mean(data(mask,6));
        data(i,7) = mean(data(mask,7)) * (min(3,matches)/3);
        mask(i) = 0;
        data(mask,:) = [];
        fprintf("Merged %d popins on identical indices\n",matches);
    end
end

function data = merge_neighbours(data,range)
    for i = 1:size(data,1)
        if(i > size(data,1))
            break; % Weil: Löschen von elementen
        end

        mask(size(data,1),1) = zeros;
        mask = logical(mask);
        mask(i) = 1;

        for j = min(size(data,1),i+1)
            if(data(j,1) - data(i,1) <= range)
                mask(j) = 1;
                if(data(j,1) - data(i,1) == range)
                    range = range + 1;
                end
            end
        end
        
        matches = sum(mask);
        
        tmp = data(mask,1);
        data(i,1) = median(data(mask,1));
        data(i,2) = median(data(mask,2));
        data(i,3) = median(data(mask,3));
        data(i,4) = mean(data(mask,4));
        data(i,5) = mean(data(mask,5));
        data(i,6) = mean(data(mask,6));
        data(i,7) = mean(data(mask,7)) * (min(3,matches)/3);
        mask(i) = 0;
        data(mask,:) = [];
        fprintf("Merged %d popins on identical indices\n",matches);
    end
end