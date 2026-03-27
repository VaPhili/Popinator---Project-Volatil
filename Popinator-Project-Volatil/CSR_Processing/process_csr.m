
function process_csr( ...
    path, ...
    file, ...
    remove_below, ... % removes values below a certain x
    sample_rate, ... % stepsize during supersampling in boundary_denoise
    sample_consideration_range, ... % sample consideration range during supersampling in boundary_denoise
    width_slope_treshold, ... % maximum distance between linear slope and actual graph during popin evaluation
    minimum_evaluation ... % score requirement for popins to be accepted. Between 0 and 1.
    )


    % Load the file, By default : Depth nm - Load µN - Time s - Depth V - Load V
    fid = fopen(fullfile(path,file));
    raw_data = cell2mat(textscan(fid,'%f %f %f %f %f','HeaderLines',5));
    fclose(fid);

    % Exctract relevant value interval (between flat area and maximum)
    max = get_max_value(raw_data, 2);
    max = max * 0.98;
    max_i = get_closest_index(raw_data, 2, max);
    min_i = get_closest_index(raw_data, 2, remove_below); %TODO? detect line automatically! on CMX:0
    limit = raw_data(min_i:max_i, 1:2);
    limit = limit(limit(:,1) >= 0, :);
      raw_preview = raw_data(raw_data(:,1) >= 0, :);

    if size(limit,1) == 0
        return
    end
    if get_max_value(limit,1) - get_min_value(limit,1) < sample_rate * 15
        return
    end
    
    % Boundary denosie  
    [median_boundary, lower_boundary, upper_boundary, boundary_distance] = boundary_denoise(limit,sample_rate,sample_consideration_range);

    % Popin Detection and Filtering
    median_popin_index = 1:size(median_boundary,1);
    boundary_distance_popin_index = 1:size(boundary_distance,1);
    combined_popin_index = 1:size(median_boundary,1);

    median_gradient = get_gradient(median_boundary);
    median_popin_index = minima_filter(median_popin_index,median_gradient);
    boundary_distance_popin_index = minima_filter(boundary_distance_popin_index,boundary_distance);
    combined_gradient = median_gradient(:,1:2);
    combined_gradient(:,2) = median_gradient(:,2) .* boundary_distance(:,2);
    combined_popin_index = minima_filter(combined_popin_index, combined_gradient);
   

    popin_data = dual_popindata_merge( ...
        limit, ...
        lower_boundary, ...
        upper_boundary, ...
        median_boundary, ...
        median_gradient, ...
        combined_gradient, ...
        boundary_distance, ...
        median_popin_index, ...
        boundary_distance_popin_index, ...
        combined_popin_index, ...
        width_slope_treshold, ...
        minimum_evaluation ...
    );




    % Statistical Analysis
    str_name = strrep(strrep(file,'_','\_'),'.txt',' ');
    str_amount = size(popin_data,1);
    str_maxSize = get_max_value(popin_data, [4,5]);
    str_minSize = get_min_value(popin_data, [4,5]);
    str_avgSize = get_average_value(popin_data, [4,5]);
    str_maxSlope = get_max_value(popin_data, 6);
    str_minSlope = get_min_value(popin_data, 6);
    str_avgSlope = get_average_value(popin_data, 6);
    str_minEval = get_min_value(popin_data, 7);
    str_maxEval = get_max_value(popin_data, 7);
    str_avgEval = get_average_value(popin_data, 7);

    str_total = {str_name,"Amount: "+str_amount, ...
        "Max Size: "+str_maxSize+" nm", "Min Size: "+str_minSize+" nm", "Average Size: "+str_avgSize+" nm", ...
        "Max Slope: "+str_maxSlope+" µN/nm", "Min Slope: "+str_minSlope+" µN/nm", "Average Slope: "+str_avgSlope+" µN/nm", ...
        "Max Eval: "+str_maxEval, " Min Eval: "+str_minEval, " Average Eval: "+str_avgEval ...
    };
    str_short = {str_name,"Popin Amount: "+str_amount};



    set(gcf,'Position',[100,10,800,600])
    plot(raw_preview(:,1),raw_preview(:,2),'.');            % original data
    hold on
        plot(lower_boundary(:,1),lower_boundary(:,2));      % Boundaries (Low)
        plot(upper_boundary(:,1),upper_boundary(:,2));      % Boundaries (Up)
        plot(median_boundary(:,1),median_boundary(:,2));    % Boundaries (Median)

        stem(median_gradient(:,1),median_gradient(:,2),'.');% Median Gradient

        stem(popin_data(:,2),popin_data(:,3),'x')           % Popins
        errorbar(popin_data(:,2),popin_data(:,3),popin_data(:,4),popin_data(:,5),'horizontal','LineStyle','none','CapSize',20)

        stem(popin_data(:,2),popin_data(:,7) * 100,'x')      % Evaluation

        text(2, max-max*0.05, str_short);
        legend({"Raw Data", "Lower Boundary", "Upper Boundary", "Median Data", "Median Gradient [µN/nm]", "Popin", "Popin Width", "Popin Evaluation [0-100%]"},'Location','SouthEast')
    
        xlabel('Depth [nm]')
        ylabel('Force [µN]');
    hold off
    
    
    % export data
    fileout = strsplit(file,'.txt');
    fileout = fileout(1);
    fileout_data = fileout + "_popindata.txt";
    fid = fopen(path + fileout_data,'w');
    
    % Header
    fprintf(fid,'Amount of PopIns -\tAverage Width -\tMaximum Width -\tMinimum Width\n');
    fprintf(fid,'%4d\t  \t\t%6.4f  \t%6.4f  \t%6.4f\n',str_amount,str_avgSize,str_maxSize,str_minSize);
    fprintf(fid,'\n');

    fprintf(fid, '%s %s %s %s %s %s %s\n', 'Index', 'X_Position_[nm]', 'Y_Position_[µN]', 'Width-Left_[nm]', 'Width-Right_[nm]', 'Slope_[µN/nm]', 'Evaluation_Score_[0-1]');
    for i = 1:size(popin_data,1)
        fprintf(fid,'%3d\t%8.6f\t%12.6f\t%5.6f\t%5.6f\t%6.6f\t%1.3f\n',i,popin_data(i,2),popin_data(i,3),popin_data(i,4),popin_data(i,5),popin_data(i,6),popin_data(i,7));
    end
    fclose(fid);


    % export plot
    fileout_graph = fileout + "_graph.png";
    exportgraphics(gcf,path + fileout_graph,'Resolution',400);
end