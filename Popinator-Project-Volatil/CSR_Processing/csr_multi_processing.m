% close previous windows
clc, clearvars, clf, close all;



[file,path] = uigetfile('*.txt','CRS_0_01_SR_0003.txt','MultiSelect','on');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end
if ~iscell(file)
    file = {file};
end

is_cmx = contains(cell2mat(file(1)),"CMX");
is_cmxsr = contains(cell2mat(file(1)),"CMX_SR");
is_Vi = contains(cell2mat(file(1)),"Vi");


% Input parameters
uiprompt = {'Remove below','Sample Rate [nm]','Sample Consideration Range [nm]','Width Slope Evaluation Treshold [µN]', "Mininum Evaluation [0-1]"};

definput_cmx = {'25','0.3','0.8','8','0.75'};
definput_cmxsr = {'25000','0.3','0.8','8','0.75'};
definput_crs = {'5200','0.3','0.8','8','0.75'};
definput_Vi = {'1000','0.5','0.8','8','0.75'};
if is_Vi
    uianswer = inputdlg(uiprompt,'Parameter Input',[1 35],definput_Vi);
elseif is_cmx
    uianswer = inputdlg(uiprompt,'Parameter Input',[1 35],definput_cmx);
elseif is_cmxsr
    uianswer = inputdlg(uiprompt,'Parameter Input',[1 35],definput_cmxsr);
else
    uianswer = inputdlg(uiprompt,'Parameter Input',[1 35],definput_crs);
end

remove_below =         str2double(cell2mat(uianswer( 1,1))); % recommended: 5200 for CSR, 20 for CMX
sample_rate =           str2double(cell2mat(uianswer( 2,1)));
sample_range =          str2double(cell2mat(uianswer( 3,1)));
widthslope_treshold =   str2double(cell2mat(uianswer( 4,1)));
mininum_evaluation =    str2double(cell2mat(uianswer( 5,1)));


% Process Files
amount = size(file,2);
for i = 1:amount
    tmp_file = cell2mat(file(i));
    process_csr(path, tmp_file, remove_below, sample_rate, sample_range, widthslope_treshold, mininum_evaluation);
end

