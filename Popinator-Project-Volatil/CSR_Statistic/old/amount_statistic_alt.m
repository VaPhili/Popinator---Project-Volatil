
% TODO, x axis logaritmisch

function amount_statistic(data,path)

    % x: rate, y:amount, hor:type(Anlassstufe), ver:Material (here just vit105), col:num
    
    datasets = size(data,1);
    % data is a cell array with each column being a 1x7 cell with metadata
    % and a (nx1)x5 cell of popin events according to the filetype   
                        % data{i,1} = {metatype metarate metanum metamethod metadate metamaterial}; OLD
    % data{i,1} = {1:metamaterial 2:metatemperature 3:metarate 4:metanum 5:metamethod 6:metadate 7:metatime};
    % data[i,2} = popins: X - Y - Width L - Width R - Angle

    tmp = data(:,1);
    metadata = vertcat(tmp{:});
    metamaterials = cell2mat(metadata(:,1));
    metatemperatures = cell2mat(metadata(:,2));
    metarates = cell2mat(metadata(:,3));
    %metanums = cell2mat(metadata(:,4));

    materials = unique(metamaterials)';
    rates = unique(metarates)';
    temperatures = unique(metatemperatures)';

    %types = {268, 278, 288, 298, 420};

    colors = ["#0072BD", "#D95319", "#EDB120", "#7E2F8E", "#77AC30", "#4DBEEE", "#A2142F"];

    % For the average + error plot
    average = zeros(size(rates,2),4,size(temperatures,1)); % Amount(avg), Error(Standartfehler), rate, amount. before calculation: sum, 0, rate, amount
    % Standartfehler = Standartabweichung der Grundgesamtheit / squrt(menge)


    % export data (header)
    fileout_data = "Statistic_Amount_All.txt";
    fid = fopen(path + fileout_data,'w');
    fprintf(fid,'%s %s %s %s %s\n','Amount','Material','Temperature','Strainrate','Number');

    % Plot all necessary graphs
    plots = [];
    t = tiledlayout(1,5);
    hold on;

        % Anlassstufen (temperatures)
        for i = 1:size(temperatures,2)

            plots(end+1) = nexttile;
            
            % Numbers
            out = [];
            o = 0;
            for n = 1:datasets
                if data{n,1}{1,2} == temperatures(i)

                    % HERE ACTUAL LOCAL GRAPHS
                    amount = size(data{n,2},1);
                    rate = data{n,1}{1,3};
                    o=o+1;
                    out(o,1) = rate;
                    out(o,2) = amount;

                    % For average:
                    for r = 1:size(rates,2) % bloated and ugly, if time: improve
                        if rate == rates(r)
                            average(r,1,i) = average(r,1,i)+ amount;
                            average(r,4,i) = average(r,4,i)+ 1.0;
                            average(r,3,i) = rate;
                            break;
                        end
                    end

                    %scatter(rate(:), amount(:));
                    % Export Data
                    fprintf(fid,'%6d %8s         %3d       %2.2f  %5s \n',amount, data{n,1}{1,1}, data{n,1}{1,2}, rate, data{n,1}{1,4}); 
                end
            end
            scat = scatter(out(:,1),out(:,2));
            scat.MarkerEdgeColor = colors(i);
            set(gca, 'XScale', 'log');
            title('Type: '+string(temperatures(i)));
            xlabel('Strainrate [nm/s]')
            ylabel('Amount');
        end
        fclose(fid);
        fileout_avg = "Statistic_Amount_Average.txt";
        fid = fopen(path + fileout_avg,'w');
        fprintf(fid,'%s %s %s %s %s\n','Average_Amount','Standart_Error','Strainrate','Temperature','Material');

        % Plot average
        plots(end+1) = nexttile;
        hold on;
        for p = 1:size(average,3) % set average
            for r = 1:size(rates,2)
                avg = double(average(r,1,p)) / double(average(r,4,p));
                average(r,1,p) = avg;
                average(r,2,p) = 0;
            end
        end
        for i = 1:1%s % calculate error
            for n = 1:datasets
                if data{n,1}{1,2} == temperatures(i)
                    amount = size(data{n,2},1);
                    for r = 1:size(rates,2) % bloated and ugly, if time: improve
                        if data{n,1}{1,3} == rates(r)
                            average(r,2,i) = double(average(r,2,i) + double(amount - average(r,1,i))*double(amount - average(r,1,i)));
                            break;
                        end
                    end
                end
            end
        end
        h = [];
        for p = 1:size(average,3) % plot
            for r = 1:size(rates,2)
                err = sqrt(double(average(r,2,p)) / double(average(r,4,p))); % standartabweichung
                err = err / sqrt(double(average(r,4,p))); % Standartfehler
                average(r,2,p) = err;
    
                % Output file
                fprintf(fid,'%4.2f \t\t%3.4f \t\t%2.2f \t%3s \t%8s\n',average(r,1,p), average(r,2,p), rates(r), temperatures(p), materials(1)); %change material
            end
            e = errorbar(average(:,3,p),average(:,1,p),average(:,2,p),'x'); 
            e.MarkerEdgeColor = colors(p);
            h(end+1) = e;                    
        end
        fclose(fid);

        colororder(colors(:))
        %tmp = cellfun(@num2str,temperatures,'un',0);
        tmp = num2str(temperatures);
        legend(h, tmp);
        title('Combined');
        xlabel('Strainrate [nm/s]')
        ylabel('Amount');

        linkaxes(plots, 'y');
        linkaxes(plots, 'x');
        set(gca, 'XScale', 'log');
    hold off;
    %title(t, 'Popin Amount statistic','Interpreter','none');
    set(gcf,'Position',[100,100,1000,600]);


    % export plot
    fileout_graph = "Statistic_Amount.png";
    exportgraphics(gcf,path + fileout_graph,'Resolution',300);
    
    
    % export average
    % TODO


    % Columns: amount, material, rate, type, num
end