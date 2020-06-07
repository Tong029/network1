clc
clear all
close all
name = {'EPR','FR','NR','NATR'};
rng(0);
for j = 1:4
    for i = 1:10
       [rmse(i),r2(i)] = trfunct(i,name{j});  
    end
    clear data
    clear data_cell
    clear result
    data = [rmse',r2'];
    [m, n] = size(data); 
    data_cell = mat2cell(data, ones(m,1), ones(n,1));
    title = {'rmse', 'r2'};  
    result = [title; data_cell];
%     filename = strcat(name{j},'logsig_purelin.xls');
%     filename = strcat(name{j},'tansig_purelin.xls');
%     filename = strcat(name{j},'logsig_tansig_purelin.xls');
%     filename = strcat(name{j},'logsig_logsig_purelin.xls');
%     filename = strcat(name{j},'tansig_logsig_purelin.xls');
    filename = strcat(name{j},'tansig_tansig_purelin.xls');
    s = xlswrite(filename, result);
end