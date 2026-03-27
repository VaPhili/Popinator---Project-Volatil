% Attempts denoising by determining upper and lower boundary of the noise
% and creates an average between those two. This should help preserve
% popins while also removing noise.

function [mid, lower, upper, distance] = boundary_denoise(data, sample_rate, sample_consideration_range)
    % originally - rate: 0.5, range: 0.8

    lower_bound = detect_lower_boundary(data);
    upper_bound = flip(detect_upper_boundary(data),1);


    lower_supersample = supersample_denoise(lower_bound,sample_rate,sample_consideration_range);
    upper_supersample = supersample_denoise(upper_bound,sample_rate,sample_consideration_range);

    s = min(size(lower_supersample,1),size(upper_supersample,1));
    lower_supersample = lower_supersample(1:s,:);
    upper_supersample = upper_supersample(1:s,:);
    
    median_supersample = (lower_supersample + upper_supersample) .* 0.5;

    scatter(data(:,1),data(:,2),10,'.')
    hold on
    %plot(lower_bound(:,1),lower_bound(:,2))
    plot(upper_supersample(:,1),upper_supersample(:,2))
    %plot(upper_bound(:,1),upper_bound(:,2))
    plot(lower_supersample(:,1),lower_supersample(:,2))

    plot(median_supersample(:,1),median_supersample(:,2))
    legend()
    hold off

    mid = median_supersample;
    lower = lower_supersample;
    upper = upper_supersample;

    distance = get_distances(mid, upper, lower);
    %distance(size(mid_supersample,1),2) = zeros;
    %distance(:,1) = mid_supersample(:,1);
    %distance(:,2) = abs((upper(:,2) - mid(:,2)) + (mid(:,2) - lower(:,2)));
end


function lb = detect_lower_boundary(dat)
    dat_sorted = sortrows(dat,1); % Sort data by x-values

    lb = []; % Initialize list of lower boundary indices
    min_idx = 1; % Start with a very large y-value

    idx = min_idx;
    while idx < size(dat_sorted,1)
        for i = idx:size(dat_sorted,1)
            if dat_sorted(i,2) < dat_sorted(min_idx,2)
                min_idx = i;
            end
        end
        idx = min_idx + 1;
        lb = [lb; dat_sorted(min_idx,:)];
        min_idx = idx;
    end
end

function ub = detect_upper_boundary(dat)
    dat_sorted = sortrows(dat,1); % Sort data by x-values

    ub = []; % Initialize list of lower boundary indices
    max_idx = size(dat_sorted,1); % Start with a very small y-value

    idx = max_idx;
    while idx > 1
        for i = 1:idx
            if dat_sorted(i,2) > dat_sorted(max_idx,2)
                max_idx = i;
            end
        end
        idx = max_idx - 1;
        ub = [ub; dat_sorted(max_idx,:)];
        max_idx = idx;
    end
end

function dist = get_distances(median, up, low)
    %for each point in upper: find point in lower. Then find point in
    %median close to both and associate with them?
    % or: find up and low point close to median, point on the other of
    % each, take minimum
    dist(size(median),2) = zeros;
    dist(:,1) = median(:,1);

    for i = 1:size(dist,1)
        
        [~, start_upidx] = min(abs(up(:,2) - median(i,2)));
        [~, start_lowidx] = min(abs(low(:,2) - median(i,2)));

        [~, end_lowidx] = min(abs(low(:,2) - up(start_upidx,2)));
        [~, end_upidx] = min(abs(low(start_lowidx,2) - up(:,2)));


        uptolow_dist = sqrt( abs((up(start_upidx,2) - low(end_lowidx,2))) * abs((up(start_upidx,2) - low(end_lowidx,2))) + abs((up(start_upidx,1) - low(end_lowidx,1))) * abs((up(start_upidx,1) - low(end_lowidx,1))) );
        lowtoup_dist = sqrt( abs((up(end_upidx,2) - low(start_lowidx,2))) * abs((up(end_upidx,2) - low(start_lowidx,2))) + abs((up(end_upidx,1) - low(start_lowidx,1))) * abs((up(end_upidx,1) - low(start_lowidx,1))) );

        dist(i,2) = min(lowtoup_dist, uptolow_dist);
    end
end