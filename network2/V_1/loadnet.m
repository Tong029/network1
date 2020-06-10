clc
close all
clear all
load ('net');
load FRExtension;
load FRRate;
load FRLoad;
tstrate = repmat(0:6:600,100+1,1).';
tstrate = tstrate.';
tstrate = tstrate(1:end);% save all the data as an array
tstex = repmat(0:100,101,1);
tstex = tstex.';
tstex = tstex(1:end);% save all the data as an array
predicting = {sim(net,[tstex;tstrate]),tstex,tstrate}; % simulation 
%     path = strcat('.\',name{n},'net\',name{n},'predicting');
figure;
scatter3(tstex,tstrate,predicting{1},'B');
hold
scatter3(FRExtension,FRRate,FRLoad,'R');
clear net
