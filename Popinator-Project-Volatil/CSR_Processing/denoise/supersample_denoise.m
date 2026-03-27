% replaces the whole dataset by new points:
% Every "stepsize"-distance on the x axis, "range" is the range on the x
% axis that is used for determining the average
% datadensity is a distance between datapoints

function out = supersample_denoise(in, stepsize, rangefactor) % TODO MAKE RANGEFACTOR DEPENDENT ON LOCAL DENSITY

    maxx = in(end,1);
    minx = in(1,1);

    %dpointdist = abs(in(end-150,1)-in(end,1))/150.0;
    %dpointdist = 0.5;
    %range = dpointdist * rangefactor;
    range = rangefactor * stepsize;
    %stepsize = dpointdist * stepsizefactor;

    out = zeros(floor((maxx-minx)/stepsize),2);
    index = 0;
    zerocounter = 0; % For interpolation steps without any close neighbours

    for x = minx:stepsize:maxx
        index = index+1;
        
        %valx = 0.0;
        valy = 0.0;
        n = 0; % weighted, for making closer points more relevant

        for i = 1:size(in,1)
            dist = abs(in(i,1) - x);
            if dist <= range

                % simple
                % factor = 1.0;

                % linear
                %factor = 1 - (dist / range);

                % root
                %factor = sqrt(1 - (dist / range));

                % quadrtatic
                factor = (1 - (dist / range))*(1 - (dist / range));

                valy = valy + (in(i,2))*factor;
                n = n+factor;
            end
        end
        
        if n == 0
            % PROBLEMATISCH! VERURSACHT TREPPEN-ARTEFAKTE BEI ZU HOHER
            % ABTASTRATE
            zerocounter = zerocounter + 1;
            out(index,:) = [x, out(index-1,2)]; % Placeholder
        else
            out(index,:) = [x, valy/n];
            
            %{
            if zerocounter > 0
                spoint = out(index-zerocounter-1,:);
                epoint = out(index,:);
                dist = epoint(1) - spoint(1);
                height = epoint(2) - epoint(1);
                for z = 1:zerocounter
                    out(index-z,2) = spoint(2) + height * (dist/(zerocounter-(z-1)));
                end
            end
            %}
            zerocounter = 0;
        end
    end

    out(any(isnan(out), 2), :) = [];
end