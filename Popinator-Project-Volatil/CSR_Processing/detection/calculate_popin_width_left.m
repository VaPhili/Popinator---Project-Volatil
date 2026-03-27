
function refl = calculate_popin_width_left(refi, reference_data, stepsize, slope, treshold, failtolerance)
    
    refli = refi-1;
    refl = 0;
    failcount = 0;
    while refli >= 1
        linear_pos = reference_data(refi,2) - (refi-refli) * stepsize * slope;
        dist = abs(linear_pos - reference_data(refli,2));
        if dist < treshold
        failcount = 0;
            refl = reference_data(refi,1)-reference_data(refli,1);
        else
            failcount = failcount+1;
        end
        refli = refli-1;

        if failcount >= failtolerance
            break
        end
    end
end