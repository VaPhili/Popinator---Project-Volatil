function max_size_statistic(data,path,filtertext)

    % x: rate, y:amount
    % hor: Temperature + all combined
    % ver: Material + all combined
    % bottom left: total combined
    % Col = material, symbol = temperature
    
    % Filter text is included in the export names
    
    datasets = size(data,1);
    % data is a cell array with each column being a 1x7 cell with metadata
    % and a (nx1)x5 cell of popin events according to the filetype   
    % data{i,1} = {1:metamaterial 2:metatemperature 3:metarate 4:metanum 5:metamethod 6:metadate 7:metatime};
    % data{i,2} = popins: X - Y - Width L - Width R - Angle

    tmp = data(:,1);
    metadata = vertcat(tmp{:});
    %metamaterials = string(cell2mat(metadata(:,1)));
    metamaterials = string(metadata(:,1));
    metatemperatures = cell2mat(metadata(:,2));
    metarates = cell2mat(metadata(:,3));
    %metanums = cell2mat(metadata(:,4));

    materials = unique(metamaterials);
    rates = unique(metarates);
    temperatures = unique(metatemperatures);

    colors = ["#0072BD", "#D95319", "#EDB120", "#7E2F8E", "#77AC30", "#4DBEEE", "#A2142F"];
    symbols = ["o","^","*","square","diamond","v",">","<","+"];

    % For the average + error plot
    stats = cell(size(temperatures,1),size(materials,1),size(rates,1));

    % export data (header)
    fileout_data = "Statistic"+filtertext+"_MaxPopinSize_All.txt";
    fid = fopen(path + fileout_data,'w');
    fprintf(fid,'%s %s \t%s %s %s %s %s\n','Displacement_[nm]','Load_[µN]', 'Size_[nm]','Material','Temperature','Strainrate','Number');

    % set stats and complete statistic
    for n = 1:datasets
        temp = find(temperatures == data{n,1}{1,2});
        mat = find(materials == data{n,1}{1,1});
        rate = find(rates == data{n,1}{1,3});

        % if stats is still empty, initialize it
        if isempty(stats{temp,mat,rate})
            stats{temp,mat,rate} = [];
        end

        % append stats for the average and plot
        if size(data{n,2},1) == 0
            continue
        end
        [~, idx] = max(data{n,2}(:,3) + data{n,2}(:,4));
        stats{temp,mat,rate} = [stats{temp,mat,rate}, data{n,2}(idx,3) + data{n,2}(idx,4)]; 

        % export to file
        fprintf(fid,'%5.5f \t  %5.5f \t %5.5f \t %8s         %3d       %2.2f  %5s \n',data{n,2}(idx,1), data{n,2}(idx,2), data{n,2}(idx,3) + data{n,2}(idx,4), data{n,1}{1,1}, data{n,1}{1,2}, rate, data{n,1}{1,4}); 
    end

    fclose(fid);

    
    % Prepare plots and file export of averages
    plots = [];
    t = tiledlayout( size(temperatures,1) +1 , size(materials,1) +1 , 'TileSpacing', 'none', 'Padding', 'none');
    hold on;

    fileout_avg = "Statistic"+filtertext+"_MaxPopinSize_Average.txt";
    fid = fopen(path + fileout_avg,'w');
    fprintf(fid,'%s %s %s %s %s\n','Average Size [nm]','Standart_Error','Strainrate','Temperature','Material');

    % Sets averages
    avg_stats = zeros(size(temperatures,1),size(materials,1),size(rates,1),2);
    for temp = 1:size(temperatures,1)
        for mat = 1:size(materials,1)
            for rate = 1:size(rates,1)

                if size(stats{temp,mat,rate},1) == 0
                    continue
                end

                % mean
                avg_stats(temp,mat,rate,1) = mean(stats{temp,mat,rate});
                % standart error
                avg_stats(temp,mat,rate,2) = std(stats{temp,mat,rate}) / sqrt(size(stats{temp,mat,rate},1));

                fprintf(fid,'%5.4f  \t  %3.4f\t\t%2.2f\t  %3d\t   %8s\n',avg_stats(temp,mat,rate,1), avg_stats(temp,mat,rate,2), rates(rate), temperatures(temp), materials(mat));
            end
        end
    end
    fclose(fid);

    % Plot all and export averages
    for temp = 1:size(temperatures,1)
        for mat = 1:size(materials,1)
            
            % Plot normal data
            tmp = [];
            for rate = 1:size(stats,3)
                if size(stats{temp,mat,rate},1) == 0
                    tmp_size = [];
                else
                    tmp_size = stats{temp, mat, rate};
                end
                tmp_rate = rates(rate) * ones(size(tmp_size(:)));
                tmp = [tmp; [tmp_rate, tmp_size(:)]];
            end
            
            plots(end+1) = nexttile;
            scat = scatter(tmp(:,1),tmp(:,2));
            scat.MarkerEdgeColor = colors(mat);
            scat.Marker = symbols(temp);
            set(gca, 'XScale', 'log');
            title(materials(mat)+', temp: '+string(temperatures(temp)));
            xlabel('Strainrate [nm/s]')
            ylabel('Size [nm]')

        end

        
        % Plot and compute average per temperature
        plots(end+1) = nexttile;
        errs = [];
        for mat = 1:size(materials,1)
            
            err = errorbar(rates(:),squeeze(avg_stats(temp,mat,:,1)),squeeze(avg_stats(temp,mat,:,2)));
            err.Color = colors(mat);
            err.Marker = symbols(temp);
            errs(end+1) = err;
            hold on
        end
        hold off
        set(gca, 'XScale', 'log');
        lgd = legend(errs, materials);
        title('All Materials, temp: '+string(temperatures(temp)));
        xlabel('Strainrate [nm/s]')
        ylabel('Size [nm]')

    end


    % Plot and compute average per material
    for mat = 1:size(materials,1)
        plots(end+1) = nexttile;
        errs = [];
        for temp = 1:size(temperatures,1)

            err = errorbar(rates(:),squeeze(avg_stats(temp,mat,:,1)),squeeze(avg_stats(temp,mat,:,2)));
            err.Color = colors(mat);
            err.Marker = symbols(temp);
            errs(end+1) = err;
            hold on
        end
        hold off
        set(gca, 'XScale', 'log');
        lgd = legend(errs, num2str(temperatures));
        title(materials(mat)+', All Temperatures');
        xlabel('Strainrate [nm/s]')
        ylabel('Size [nm]')
    end


    % Plot and compute total average
    plots(end+1) = nexttile;
    errs = [];
    for temp = 1:size(temperatures,1)
        for mat = 1:size(materials,1)
            err = errorbar(rates(:),squeeze(avg_stats(temp,mat,:,1)),squeeze(avg_stats(temp,mat,:,2)));
            err.Color = colors(mat);
            err.Marker = symbols(temp);
            errs(end+1) = err;
            hold on
        end
    end
    hold off
    set(gca, 'XScale', 'log');
    [tmp1, tmp2] = ndgrid(materials,string(num2str(temperatures)));
    tmp = tmp1(:) + ", " + tmp2(:);
    lgd = legend(errs, tmp);
    title('All Combined');
    xlabel('Strainrate [nm/s]')
    ylabel('Size [nm]')

    
    % export plot
    linkaxes(plots, 'y');
    linkaxes(plots, 'x');
    hold off;
    set(gcf,'Position',[100,100,2000,1500]);
    
    fileout_graph = "Statistic"+filtertext+"_MaxPopinSize.png";
    exportgraphics(gcf,path + fileout_graph,'Resolution',300);
end