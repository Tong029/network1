clc
clear all
close all
name = {'EPR','FR','NR','NATR'};
rng(0);
for ii = 1:6
    for j = 1:4
        for i = 1:10
           delete net.mat
           delete 1.mat
           [rmse(i),r2(i)] = trfunct(i,name{j},ii);  
        end
        clear data
        clear data_cell
        clear result
        data = [rmse',r2'];
        [m, n] = size(data); 
        data_cell = mat2cell(data, ones(m,1), ones(n,1));
        title = {'rmse', 'r2'};  
        result = [title; data_cell];
        if ii == 1
            filename = strcat(name{j},'tansig_tansig_purelin.xls');     
        elseif ii == 2
            filename = strcat(name{j},'logsig_tansig_purelin.xls');
        elseif ii == 3
            filename = strcat(name{j},'tansig_logsig_purelin.xls');           
        elseif ii == 4
            filename = strcat(name{j},'logsig_logsig_purelin.xls');            
        elseif ii == 5
            filename = strcat(name{j},'tansig_purelin.xls');           
        else
            filename = strcat(name{j},'logsig_purelin.xls');       
        end
        s = xlswrite(filename, result);
    end
end