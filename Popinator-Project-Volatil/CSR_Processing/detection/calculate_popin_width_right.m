

function refr = calculate_popin_width_right(refi, reference_data, stepsize, slope, treshold, failtolerance)
    
    refri = refi+1;
    refr = 0;
    failcount = 0;
    while refri <= size(reference_data,1)
        linear_pos = reference_data(refi,2) + (refri-refi) * stepsize * slope;
        dist = abs(reference_data(refri,2) - linear_pos);
        if dist < treshold
            failcount = 0;
            refr = reference_data(refri,1)-reference_data(refi,1);
        else
            failcount = failcount+1;
        end
        refri = refri+1;

        if failcount >= failtolerance
            break
        end
    end
end