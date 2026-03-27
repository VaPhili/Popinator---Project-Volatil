
% get average function:
% returns the average y value

function [data_out, filtertext] = filter_by_amount(data, amount)
    
    filtertext = "_first_"+num2str(amount)+"_popins";
    
    % data is a cell array with each column being a 1x7 cell with metadata
    % and a (nx1)x5 cell of popin events according to the filetype   
    % data{i,1} = {1:metamaterial 2:metatemperature 3:metarate 4:metanum 5:metamethod 6:metadate 7:metatime};
    % data{i,2} = popins: X - Y - Width L - Width R - Angle

    for i = 1:size(data,1)
        popindata = data{i,2};
        popindata = popindata(1:min(amount,size(popindata,1)),:);
        data{i,2} = popindata;
    end

    data_out = data;
end