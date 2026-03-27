% close previous windows
clc, clearvars, clf;


[files,path] = uigetfile('*_popins.txt','CRS_0_01_SR_0003_popins.txt','MultiSelect','on');
if isequal(files,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,files)]);
end


% Input parameters
uiprompt = {'Naming Convention:','Only first [nm]:','Only first x popins:', ...
    'Create Amount Statistic','Create Position Amount Statistic','create First Popin Position Statistic', ...
    'Create Largest Popin Position Statistic', 'Create Size Amount Statistic', 'Create Average Size Statistic', ...
    'Create Max Size Statistic', 'Create Angle Amount Statistic', 'Create Average Angle Statistic' ...
    };
options = {'CSR_RATE_SR_NUM','MAT_METH_RATE_DATE_NUM','CSR_TYPE_RATE_NUM','MAT_TEMP_Omniprobe_METH_RATE_DATE_TIME_NUM'};
definput = {'MAT_TEMP_Omniprobe_METH_RATE_DATE_TIME_NUM','-1','-1','Y','Not Implemented','Y','Y', ...
    'Not Implemented','Not Implemented','Y','Not Implemented','Not Implemented'};
uianswer = inputdlg(uiprompt,'Parameter Input',[1 65],definput);


namecon = cell2mat(uianswer(1,1));     % recommended: CSR_TYPE_RATE_NUM
limitnm = str2double(uianswer(2,1));
limitamount = str2double(uianswer(3,1));
do_amount_statistic = cell2mat(uianswer(4,1));
do_positionamount_statistic = cell2mat(uianswer(5,1));
do_firstpopinposition_statistic = cell2mat(uianswer(6,1));
do_largestpopinposition_statistic = cell2mat(uianswer(7,1));
do_sizeamount_statistic = cell2mat(uianswer(8,1));
do_averagesize_statistic = cell2mat(uianswer(9,1));
do_maxsize_statistic = cell2mat(uianswer(10,1));
do_angleamount_statistic = cell2mat(uianswer(11,1));
do_averageangle_statistic = cell2mat(uianswer(12,1));


% Extract Data
data = extract_data(path,files,namecon);

% Analysis Files
statistic_csr(data, path, ...
    limitnm, limitamount, ...
    strcmp(do_amount_statistic,'Y'), ...
    strcmp(do_positionamount_statistic,'Y'), ...
    strcmp(do_firstpopinposition_statistic,'Y'), ...
    strcmp(do_largestpopinposition_statistic,'Y'), ...
    strcmp(do_sizeamount_statistic,'Y'), ...
    strcmp(do_averagesize_statistic,'Y'), ...
    strcmp(do_maxsize_statistic,'Y'), ...
    strcmp(do_angleamount_statistic,'Y'), ...
    strcmp(do_averageangle_statistic,'Y') ...
);