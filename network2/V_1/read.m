clc
clear all
close all
filename = {'EPR','FR','NR','NATR'};
for i = 2:2
    whichfold = filename{i};
    path = strcat({'.\'},{whichfold},{'predicting_load_ex_rate'});
    x = 1;
    dataStruct = struct('Load',{},'Extension',{},'Rate',{});
    dataamount = 0;
    load (path{1});
    p=[predicting{2};predicting{3}];
    t=predicting{1};
    % calculate the amount of the data
    s = size(t);% the size is saved as the second parameter in the array.
    s = [1:s(2)];% s is an Integer column upto s(2). It represents the index of the data in p and t.
    [trainset,vali] =dividerand(s,0.9,0.1);% spare 10% data as validation set
    % to see how many data is there in the train/validation set
    sizet = size(trainset);sizet = sizet(2);
    sizev = size(vali);sizev = sizev(2);
    % copy the data from p/t to trainsample/validation according to the index
    trainsample.p(1,1:sizet) = p(1,trainset(1:sizet));
    trainsample.p(2,1:sizet) = p(2,trainset(1:sizet));
    trainsample.t(1,1:sizet) = t(1,trainset(1:sizet));
    validation.p(1,1:sizev) = p(1,vali(1:sizev));
    validation.p(2,1:sizev) = p(2,vali(1:sizev));
    validation.t(1,1:sizev) = t(1,vali(1:sizev));
%     % add 0 to train set as the load value for negative extension. 
%     for i = 1:60
%     trainsample.p(2,(sizet+1+51*(i-1)):(sizet+51*i)) =linspace(10*i,10*i,51); % rates of the 0 value are from 10 to 600. 
%     trainsample.p(1,sizet+1+51*(i-1):sizet+51*i) = [-50:0]; % extensions of zero value are from -50 to 0 for each rate
%     end
%     trainsample.t(1,sizet+1:sizet+51*i) = zeros(1,3060); %load = 0
% 
    % build a neural network with 2 hidden layers
    net = feedforwardnet([12,6]);% 2-12-6-1
%     net = feedforwardnet(10);
    % divide the data again for BR
    % net.divideParam.trainRatio = 0.9;
    % net.divideParam.testRatio = 0.1;
    % Bayes Regulization
    net.trainFcn='trainbr';
    % set the activation function of hidden layers as sigmoid
    % net.layers{1}.transferFcn = 'logsig';
    % net.layers{2}.transferFcn = 'logsig';
    % net.layers{3}.transferFcn = 'logsig';
    % train the network
    [net,tr]=train(net,trainsample.p,trainsample.t);

    save('net');
    load('net');

    %RMSE
    A = validation.p(1,:);
    B = validation.p(2,:);
    C = validation.t(1,:);
    SimRMSELoad = sim(net,[A;B]);
    MEANrmse= sqrt(mean((SimRMSELoad-C).^2));
    RRMSE = MEANrmse/max(predicting{1});
    %R2
    x = SimRMSELoad;
    y = validation.t(1,:);
    x_mean = mean(x);
    y_mean = mean(y);
    xy_mean = mean(x.*y);
    xx_mean = mean(x.*x);
    yy_mean = mean(y.*y);
    m = (x_mean * y_mean - xy_mean)/(x_mean^2 - xx_mean);
    b = y_mean - m*x_mean;
    f = m*x+b;
    sst = sum((y-y_mean).^2);
    sse = sum((y-f).^2);
    ssr = sum((f-y_mean).^2);
    MEANR2 = ssr/sst;
    
    
    load FRExtension;
    load FRRate;
    load FRLoad;
    %RMSE with original experimental data
    A = FRExtension;
    B = FRRate;
    C = FRLoad;
    originalSimRMSELoad = sim(net,[A;B]);
    originalMEANrmse= sqrt(mean((originalSimRMSELoad-C).^2));
    originalRRMSE = originalMEANrmse/max(C);
    %R2
    x = originalSimRMSELoad;
    y = C;
    x_mean = mean(x);
    y_mean = mean(y);
    xy_mean = mean(x.*y);
    xx_mean = mean(x.*x);
    yy_mean = mean(y.*y);
    m = (x_mean * y_mean - xy_mean)/(x_mean^2 - xx_mean);
    b = y_mean - m*x_mean;
    f = m*x+b;
    sst = sum((y-y_mean).^2);
    sse = sum((y-f).^2);
    ssr = sum((f-y_mean).^2);
    originalMEANR2 = ssr/sst;
end