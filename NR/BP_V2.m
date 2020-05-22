clc
clear all
close all

load .\Extension.txt;
load .\Load.txt;
load .\Rate.txt;
save Extension.mat;
save Rate.mat;
save Load.mat;
% plot (Extension,Load);
% grid
p=[Extension;Rate];
t=Load;

s = size(Load);
s = [1:s(2)];
[trainset,vali] =dividerand(s,0.9,0.1);
sizet = size(trainset);sizet = sizet(2);
sizev = size(vali);sizev = sizev(2);

trainsample.p(1,1:sizet) = p(1,trainset(1:sizet));
trainsample.p(2,1:sizet) = p(2,trainset(1:sizet));
trainsample.t(1,1:sizet) = t(1,trainset(1:sizet));

validation.p(1,1:sizev) = p(1,vali(1:sizev));
validation.p(2,1:sizev) = p(2,vali(1:sizev));
validation.t(1,1:sizev) = t(1,vali(1:sizev));

for i = 1:60
trainsample.p(2,(sizet+1+51*(i-1)):(sizet+51*i)) =linspace(10*i,10*i,51);
trainsample.p(1,sizet+1+51*(i-1):sizet+51*i) = [-50:0];
end
trainsample.t(1,sizet+1:sizet+51*i) = zeros(1,3060);

net = feedforwardnet([12,6]);

% net.trainParam.epochs=600; %Maximum number of epochs to train
% net.trainParam.goal=1e-5; %desired accuracy
net.divideParam.trainRatio = 0.9;
net.divideParam.testRatio = 0.1;

% net.trainParam.lr=0.01;%learning rate
% net.trainParam.mc=0.9;%Momentum constant
net.trainFcn='trainbr';
net.layers{1}.transferFcn = 'logsig';
net.layers{2}.transferFcn = 'logsig';
% net.layers{3}.transferFcn = 'logsig';
[net,tr]=train(net,trainsample.p,trainsample.t);
% [net,tr]=train(net,p,t);

save('net');
load('net');

%DATA without zeros added manually
load .\ERRORExtension.txt;
load .\ERRORLoad.txt;
load .\ERRORRate.txt;
load .\Amount.txt;

save ERRORExtension.mat;
save ERRORRate.mat;
save ERRORLoad.mat;
save Amount.mat;
% simulation with original input
% PLoad=sim(net,[ERRORExtension;ERRORRate]);
% scatter3(Extension,Rate,PLoad,'G');

scatter3(ERRORExtension,ERRORRate,ERRORLoad,'R');
hold on; 
% simulation with rates range from 0 to 600 and with strain from 0 to 130;
tstrate = repmat(0:12:600,101,1).';
tstrate = tstrate.';
tstrate = tstrate(1:end);
tstex = repmat(0:100,51,1);
tstex = tstex.';
tstex = tstex(1:end);
predicting = sim(net,[tstex;tstrate]);
scatter3(tstex,tstrate,predicting,'B');

title('comparation');
legend('experimental data','simulation data');
xlabel('Extansion');
ylabel('rate');
zlabel('stress');

k=1;
kk(1,1)=1;
for i = 1:sizev-1
    if validation.p(1,i+1)>validation.p(1,i)
        errorload(k,kk(k)) = validation.t(1,i);
        errorextension(k,kk(k)) = validation.p(1,i);
        errorrate(k,kk(k)) = validation.p(2,i);
        kk(k) = kk(k) + 1;
    else
        errorload(k,kk(k)) = validation.t(1,i);
        errorextension(k,kk(k)) = validation.p(1,i);
        errorrate(k,kk(k)) = validation.p(2,i);        
        k = k+1;
        if(i~=sizev-1)
            kk(k)=1;
        end
    end
end
figure
for i = 1:21
    %RMSE
    A = errorextension(i,:);
    B = errorrate(i,:);
    C = errorload(i,:);
    SimRMSELoad = sim(net,[A;B]);
    rmse(i) = sqrt(mean((SimRMSELoad-C).^2));

    %R2
    x = SimRMSELoad;
    y = errorload(i,:);
%     plot(x,y);
    x_mean = mean(x);
    y_mean = mean(y);
    xy_mean = mean(x.*y);
    xx_mean = mean(x.*x);
    yy_mean = mean(y.*y);
    m = (x_mean * y_mean - xy_mean)/(x_mean^2 - xx_mean);
    b = y_mean - m*x_mean;
    f = m*x+b;
    line(x,f);
    sst = sum((y-y_mean).^2);
    sse = sum((y-f).^2);
    ssr = sum((f-y_mean).^2);
    R2(i) = ssr/sst;
    grid
end
title('R2');
xlabel('experimental');
ylabel('simulation');
MEANrmse = mean(rmse);
MEANR2 = mean(R2);
figure
bar(rmse(1:17));
title('RMSE');
xlabel('dataset');
ylabel('RMSE');




