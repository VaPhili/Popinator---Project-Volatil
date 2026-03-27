

function [eval, total_weight] = evaluate_popins(data, scan_data, reference_data, treshold, failtolerance)
    eval = zeros(size(data,1),0);

    eval(:,end+1) = evaluate_normalized_global_height_difference(data, scan_data, 10);
    eval(:,end+1) = evaluate_global_height_difference(data, scan_data, 10);
    eval(:,end+1) = evaluate_local_height_difference(data, scan_data, 8, 10);
    eval(:,end+1) = evaluate_popin_width(data, max(scan_data,1) * 0.15, 10);
    eval(:,end+1) = evaluate_minima_neighbourhood(data, scan_data, 5, 10);
    eval(:,end+1) = evaluate_width_sensitivity_correlation(data, reference_data, treshold, 6, failtolerance+2, 10);
    eval(:,end+1) = evaluate_boundary_hit(data, scan_data, 10);
    eval(:,end+1) = evaluate_extended_boundary_hit(data, reference_data, treshold*4, failtolerance+2, 10);

    % Toleranzsprung? (=gute popins werden kaum plötzlich alles abdecken,
    % schlechtere schon eher. Wenn es also sprünge bei veränderter Toleranz
    % gibt ist es kein gutes popin.

    % Differenzgraph kriterien: klein genug, klein genug normalisiert,
    % minimum in nähe
    % Darstellung durch vertikale error?

    % Dichtegraph: klein genug normalisiert

    total_weight = size(eval,2) * 10;
end



function eval = evaluate_normalized_global_height_difference(popin_data, scan_data, weight)
    eval = zeros(size(popin_data,1),1);

    maxval = max(scan_data(:,2));
    minval = min(scan_data(:,2));
    for i = 1:size(popin_data,1)
        factor = (1 - (scan_data(popin_data(i,1),2)-minval) / (maxval - minval))^1.5;
        eval(i,1) = weight * factor;
    end
end

function eval = evaluate_global_height_difference(popin_data, scan_data, weight)
    eval = zeros(size(popin_data,1),1);

    maxval = max(scan_data(:,2));
    for i = 1:size(popin_data,1)
        factor = (1 - (scan_data(popin_data(i,1),2)) / (maxval));
        eval(i,1) = weight * factor;
    end
end

function eval = evaluate_local_height_difference(popin_data, scan_data, range, weight)
    eval = zeros(size(popin_data,1),1);

    for i = 1:size(popin_data,1)
        leftrange = max(1,popin_data(i,1)-range);
        rightrange = min(size(scan_data,1),popin_data(i,1)+range);
        localarea = scan_data(leftrange:rightrange,:);

        maxval = max(localarea(:,2));
        minval = min(localarea(:,2));
        % Ideal: Nah am minimum, entfernt vom maximum
        factor = 1 - ( scan_data(popin_data(i,1),2) - minval ) / (maxval - minval);
        eval(i,1) = weight * factor;
    end
end

function eval = evaluate_popin_width(popin_data, maxsize, weight)
    eval = zeros(size(popin_data,1),1);
    
    % should not be longer than 30% (maxsize) and larger than 0%
    % maybe startwidth and endwidth? =0:0, <min:1, min>>max:1>>0, >max:0
    % Also add a minimal width in case the area is very slim?
    for i = 1:size(popin_data,1)
        if popin_data(i,4) + popin_data(i,5) == 0
            factor = 0;
        elseif popin_data(i,4) + popin_data(i,5) > maxsize
            factor = 0;
        else
            factor = 1;
        end
        eval(i,1) = weight * factor;
    end
end

function eval = evaluate_minima_neighbourhood(popin_data, scan_data, range, weight)
    eval = zeros(size(popin_data,1),1);
    
    % amount of points smaller than x among the neighbours
    for i = 1:size(popin_data,1)
        area = (max(popin_data(i,1) - range, 1) : min(size(scan_data,1), popin_data(i,1) + range));
        areasize = size(area,2);

        matches = scan_data(area,2);
        matches = matches(matches(:) < scan_data(popin_data(i,1),2));

        matchsize = size(matches,1);
        factor = matchsize / (areasize-1);
        factor = 1 - factor;
        factor = factor * factor;

        eval(i,1) = weight * factor;
    end
end

function eval = evaluate_width_sensitivity_correlation(popin_data, reference_data, treshold, sensitivity, failtolerance, weight)
    eval = zeros(size(popin_data,1),1);
    
    % how much does the width of the popin change when lowering the
    % sensitivity treshold? A great popin should be less affected compared
    % to a bad one.

    stepsize = reference_data(2,1) - reference_data(1,1);
    for i = 1:size(popin_data,1)
        refi = popin_data(i,1);
        slope = popin_data(i,6);

        width_l = calculate_popin_width_left(popin_data(i,1), reference_data, stepsize, slope, treshold * sensitivity, failtolerance);
        width_r = calculate_popin_width_right(popin_data(i,1), reference_data, stepsize, slope, treshold * sensitivity, failtolerance);
        
        width_default = popin_data(i,4) + popin_data(i,5);
        width_sensitive = width_l + width_r;

        tolerance = stepsize * sensitivity;
        difference = width_sensitive - width_default - tolerance;

        if difference <= stepsize/2
            factor = 1;
        else
            factor = (stepsize / difference)^0.5;
        end

        % Debug plot
        linear_x = -5 : 0.1 : +5;
        linear_y = reference_data(refi,2) + linear_x * slope;
        linear_x = linear_x + reference_data(refi,1);

        plot(reference_data(:,1),reference_data(:,2))
        hold on
        stem(reference_data(refi,1),reference_data(refi,2))
        plot(linear_x, linear_y);
        errorbar(popin_data(i,2),popin_data(i,3),popin_data(i,4),popin_data(i,5),'horizontal','LineStyle','none','CapSize',20)
        errorbar(popin_data(i,2),popin_data(i,3),width_l,width_r,'horizontal','LineStyle','none','CapSize',20)
        legend()
        hold off

        eval(i,1) = weight * factor;
    end
end

function eval = evaluate_boundary_hit(popin_data, scan_data, weight)
    eval = zeros(size(popin_data,1),1);
    
    % evaluates zero if the width calculation extends to the boundary of
    % our graph
    stepsize = scan_data(2,1) - scan_data(1,1);
    minx = scan_data(1,1) + stepsize * 0.5;
    maxx = scan_data(end,1) - stepsize * 0.5;
    for i = 1:size(popin_data,1)
        factor = 1;
        if popin_data(i,2) - popin_data(i,4) <= minx
            factor = 0;
        end
        if popin_data(i,2) + popin_data(i,5) >= maxx
            factor = 0;
        end

        eval(i,1) = weight * factor;
    end
end

function eval = evaluate_extended_boundary_hit(popin_data, reference_data, treshold, failtolerance, weight)
    eval = zeros(size(popin_data,1),1);
    
    % evaluates zero if the width calculation extends to the boundary of
    % our graph
    stepsize = reference_data(2,1) - reference_data(1,1);
    minx = reference_data(1,1) + stepsize * 0.5;
    maxx = reference_data(end,1) - stepsize * 0.5;

    for i = 1:size(popin_data,1)
        slope = popin_data(i,6);

        width_l = calculate_popin_width_left(popin_data(i,1), reference_data, stepsize, slope, treshold, failtolerance);
        width_r = calculate_popin_width_right(popin_data(i,1), reference_data, stepsize, slope, treshold, failtolerance);

        factor = 1;
        if popin_data(i,2) - width_l <= minx
            factor = 0;
        end
        if popin_data(i,2) + width_r >= maxx
            factor = 0;
        end

        eval(i,1) = weight * factor;

        % Debug plot
        linear_x = -5 : 0.1 : +5;
        linear_y = reference_data(popin_data(i,1),2) + linear_x * slope;
        linear_x = linear_x + reference_data(popin_data(i,1),1);

        plot(reference_data(:,1),reference_data(:,2))
        hold on
        stem(reference_data(popin_data(i,1),1),reference_data(popin_data(i,1),2))
        plot(linear_x, linear_y);
        errorbar(popin_data(i,2),popin_data(i,3),popin_data(i,4),popin_data(i,5),'horizontal','LineStyle','none','CapSize',20)
        errorbar(popin_data(i,2),popin_data(i,3),width_l,width_r,'horizontal','LineStyle','none','CapSize',20)
        legend()
        hold off
    end
end