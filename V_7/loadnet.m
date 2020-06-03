clc
close all
clear all
thename = {'EPR','FR','NR','NATR'};
amount = [200,110,100,30];
for  n= 1:4
    k = amount(n);
    b = thename{n};
    netname = strcat('.\',b,'net\',b,'logsig_tansig_purelin_net.mat');
    path = strcat(b,'predicting_load_ex_rate');
    load (netname);
    tstrate = repmat(0:12:600,k+1,1).';
    tstrate = tstrate.';
    tstrate = tstrate(1:end);% save all the data as an array
    tstex = repmat(0:k,51,1);
    tstex = tstex.';
    tstex = tstex(1:end);% save all the data as an array
    predicting = {sim(net,[tstex;tstrate]),tstex,tstrate}; % simulation 
%     path = strcat('.\',name{n},'net\',name{n},'predicting');
    save(path);
    figure(n);
    scatter3(tstex,tstrate,predicting{1},'B');
    clear net
end