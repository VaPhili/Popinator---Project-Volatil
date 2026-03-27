
% get average function:
% returns the average y value

function out = extract_data(path,files,namecon)

    % Read Data to List
    if ~iscell(files)
        files = {files};
    end

    % get size
    amount = size(files,2);
    
    % Initialize List
    datalist = cell(amount,2);
    
    % Read the data
    for i = 1:amount
        % Read metadata

        % get relevant part of the path
        name = strsplit(files{i}, '.');
        name = name{1};

        % setup meta variables
        metamaterial = "?";
        metatemperature = "?"; %formerly: type
        metarate = 0;
        metanum = "?";
        metamethod = "?";
        metadate = "?";
        metatime = "?";

        % Other Pattern are for now not recognized  
        str = strsplit(name,'_');
        if strcmp(namecon, "CSR_TYPE_RATE_NUM")
            index = 2;

            metatemperature = str{index};
            if strcmp(metatemperature,'ac')
                metatemperature = str2double(420);
            else
                metatemperature = str2double(metatemperature);
            end
            index = index+1;
            metarate = str2double(str{index});
            index = index+1;
            if metarate == 0 % rate might be 0_X 
                metarate = str2double("0."+str{index});
                index = index+1;
            end
            if metarate == 1 && size(str{index},1) > 1 % rate might be 1.5
                metarate = str2double("1."+str{index});
                index = index+1;
            end
            metanum = str{index};
            tmp = strsplit(path,'\');
            %metamaterial = string(tmp{end-2}) + ' ' + strrep(string(tmp{end-1}),'_',' ');
            metamaterial = string(tmp{end-2});

        elseif strcmp(namecon, "CSR_RATE_SR_NUM")  
            index = 2;

            metarate = str2double(str{index});
            index = index+1;
            if metarate == 0 % rate might be 0_X
                metarate = str2double("0."+str{index});
                index = index+1;
            end
            index = index+1;
            metanum = str{index};

        elseif strcmp(namecon, "MAT_TEMP_Omniprobe_METH_RATE_DATE_TIME_NUM")
            index = 1;

            metamaterial = str{index};
            if strcmp(metamaterial, "ViTi2")
                metamaterial = 'ViTi2_5';
                index = index+1;
            elseif strcmp(metamaterial, "ViTi7")
                metamaterial = 'ViTi7_5';
                index = index+1;
            end
            metamaterial = string(metamaterial);
            index = index+1;
            metatemperature = str2double(str{index});
            index = index+2;
            metamethod = str{index};
            index = index+1;

            metarate = str2double(str{index});
            index = index+1;
            if metarate == 0 % rate might be 0_X
                metarate = str2double("0."+str{index});
                index = index+1;
            end

            % for now ignored due to irregular naming of some files
            %metadate = str{index};
            %index = index+1;
            %metatime = str{index};
            %index = index+1;
            %metanum = str{index};



        elseif strcmp(namecon, "MAT_METH_RATE_DATE_NUM")
            index = 1;

            metamaterial = str{index};
            index = index+1;
            if startswith(str{index}, numberPattern(1)) % material might be Vitxxx_xxx
                metamaterial = metamaterial+"_"+str{index};
                index = index+1;
            end
            metamethod = str{index};
            index = index+1;
            if strcmp(metamethod, "Omniprobe") % method might be for ex. omniprobe_CMX
                metamethod = metamethod+"_"+str{index};
                index = index+1;
            end
            metarate = str{index};
            index = index+1;
            if metarate == 0 % rate might be 0_X
                metarate = str2double("0."+str{index});
                index = index+1;
            end
            metadate = str{index};
            index = index+1;
            metanum = strsplit(str{index},'#');
            metanum = metanum(1);
    
        end

        % Set values
        datalist{i,1} = {metamaterial metatemperature metarate metanum metamethod metadate metatime};
        %datalist{i,1} = {metatemperature metarate metanum metamethod metadate metamaterial};

        % Read values
        tmp_file = cell2mat(files(i));
        fid = fopen(fullfile(path,tmp_file));
        dat = textscan(fid,'%f %f %f %f %f','HeaderLines',4);
        %dat = cell2mat(dat);
        fclose(fid);

        tmp = zeros(size(dat{1},1),size(dat,2));
        for x = 1:size(dat{1},1)
            for y = 1:size(dat,2)
                tmp(x,y) = dat{y}(x);
            end
        end

        datalist{i,2} = tmp;
    end

    out = datalist;
end