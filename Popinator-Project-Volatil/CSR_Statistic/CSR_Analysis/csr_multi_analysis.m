% close previous windows
clc, clearvars, clf, close all;


[file,path] = uigetfile('*_popins.txt','CRS_0_01_SR_0003_popins.txt','MultiSelect','on');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

% Input parameters
uiprompt = {'Stepsize:'}; 
% Size_Steps: represents the size classes for the size amount statistic
definput = {'0.01'};
uianswer = inputdlg(uiprompt,'Parameter Input',[1 35],definput);
stepsize = str2double(cell2mat(uianswer(1,1)));     % recommended: 0.01
%tresholdfactor = str2double(cell2mat(uianswer(2,1))); % recommended: 0.065
%widthtreshold = str2double(cell2mat(uianswer(3,1)));  % recommended: 6.0 ?



% Analysis Files
if ~iscell(file)
    file = {file};
end
amount = size(file,2);
for i = 1:amount
    tmp_file = cell2mat(file(i));
    analyse_csr(path,tmp_file,stepsize);
end