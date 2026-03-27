

function statistic_csr(data, path, firstrangefilter, firstamountfilter, ...
    do_amount, ...
    do_positionamount, ...
    do_firstpopinposition, ...
    do_largestpopinposition, ...
    do_sizeamount, ...
    do_averagesize, ...
    do_maxsize, ...
    do_angleamount, ...
    do_averageangle ...
    )

    filtertext = "";

    % apply filters
    if firstrangefilter > 0
        [data, tmptext] = filter_by_range(data, firstrangefilter);
        filtertext = filtertext + tmptext;
    end
    if firstamountfilter > 0
        [data, tmptext] = filter_by_amount(data, firstamountfilter);
        filtertext = filtertext + tmptext;
    end


    % create statistics
    if do_amount
        amount_statistic(data, path, filtertext);
    end
    %if do_positionamount
    %    position_amount_statistic(data, path, stepsize, filtertext);
    %end
    if do_firstpopinposition
        first_popin_position_statistic(data, path, filtertext);
    end
    if do_largestpopinposition % untested
        largest_popin_position_statistic(data, path, filtertext);
    end
    %if do_sizeamount
    %    size_amount_statistic(data, path, stepsize, filtertext);
    %end
    %if do_averagesize
    %    average_size_statistic(data, path, filtertext);
    %end
    if do_maxsize % Untested
        max_size_statistic(data, path, filtertext);
    end
    %if do_angleamount
    %    angle_amount_statistic(data, path, stepsize, filtertext);
    %end
    %if do_averageangle
    %    average_angle_statistic(data, path, filtertext);
    %end
end