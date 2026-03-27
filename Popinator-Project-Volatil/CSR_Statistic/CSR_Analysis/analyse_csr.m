
% get average function:
% returns the average y value

function analyse_csr(path,file,stepsize)
    fid = fopen(fullfile(path,file));

    % load graph from file
    % By default : Pos x nm - Pos y nm - Width nm - Slope µN/nm 
    data = textscan(fid,'%f %f %f %f','HeaderLines',4) ;
    data = cell2mat(data);
    fclose(fid);
    

    % Make Default Statistic
    num_of_popins = size(data,1);
    min_size = 0;
    max_size = 0;
    avg_size = 0;
    min_slope = 0;
    max_slope = 0;
    avg_slope = 0;

    % Size statistic
    sizeamountrel = sizestep_amount_relation(data,stepsize);

    % Size - Position X - Position Y - Relation
    sizeposrel = size_position_relation(data);

    % Size - Angle - Relation
    sizesloperel = size_slope_relation(data);

    % Angle - Position X - Position Y - Relation
    slopeposrel = slope_position_relation(data);

    % TODO fit mit entfernten Popins


    % Plot 
    hold on;
    t = tiledlayout(2,2);

    nexttile;
    bar(sizeamountrel(:,1),sizeamountrel(:,2));
    title("Size Amout Relation");
    xlabel("Size [nm]");
    ylabel("Amount []");

    nexttile;
    yyaxis left;
    scatter(sizeposrel(:,1),(sizeposrel(:,2)));
    ylabel("Depth [nm]");
    yyaxis right;
    scatter(sizeposrel(:,1),(sizeposrel(:,3)));
    ylabel("Load [µN]");
    title("Size Position Relation");
    xlabel("Size [nm]");

    nexttile;
    scatter(sizesloperel(:,1),sizesloperel(:,2));
    title("Size Slope Relation");
    xlabel("Size [nm]");

    nexttile;
    yyaxis left;
    scatter(slopeposrel(:,1),slopeposrel(:,2));
    ylabel("Depth [nm]");
    yyaxis right;
    scatter(slopeposrel(:,1),slopeposrel(:,3));
    ylabel("Load [µN]");
    title("Slope Position Relation");
    xlabel("Slope [µN/nm]");

    hold off;
    title(t, strsplit(file,'.txt'),'Interpreter','none');
    set(gcf,'Position',[100,100,1000,600]);


    % export data
    fileout = strsplit(file,'.txt');
    fileout = fileout(1);

    % export plot
    fileout_graph = fileout + "_analysis.png";
    exportgraphics(gcf,path + fileout_graph,'Resolution',200);
end