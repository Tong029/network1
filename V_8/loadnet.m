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
    tstrate = repmat(0:6:600,k+1,1).';
    tstrate = tstrate.';
    tstrate = tstrate(1:end);% save all the data as an array
    tstex = repmat(0:k,101,1);
    tstex = tstex.';
    tstex = tstex(1:end);% save all the data as an array
    predicting = {sim(net,[tstex;tstrate]),tstex,tstrate}; % simulation 
%     path = strcat('.\',name{n},'net\',name{n},'predicting');
%     if strcmp(name, 'EPR')
%     save('EPRpredicting_load_ex_rate','predicting');
%     elseif strcmp(name, 'FR')
%     save('FRpredicting_load_ex_rate','predicting');
%     elseif strcmp(name, 'NR')
%     save('NRpredicting_load_ex_rate','predicting');
%     else 
%     save('NATRpredicting_load_ex_rate','predicting');
%     end
    save(path,'predicting');
    figure(n);
    scatter3(tstex,tstrate,predicting{1},'B');
    clear net
end