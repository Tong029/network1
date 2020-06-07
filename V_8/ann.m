%choose one material, get the data and train the network 
clc
clear all
close all
%get data
%delete *.txt
whichfold = input('input the name of material (EPR/NR/NATR/FR): ','s');
switch1 = input('1 to obtain data');
switch2 = input('1 to train');
if switch1
    if strcmp(whichfold, 'EPR')
        patha = strcat({'.\'},{whichfold},{'\RDSO '},{whichfold},{' Tensile 50.is_tens_RawData\Specimen_RawData_'});
        pathb = strcat({'.\'},{whichfold},{'\RDSO '},{whichfold},{' Tensile 500.is_tens_RawData\Specimen_RawData_'});
        path{:,1} = patha{1};
        path{:,2} = pathb{1};
    else
        patha = strcat({'.\'},{whichfold},{'\RDSO '},{whichfold},{' Tensile 50.is_tens_RawData\Specimen_RawData_'});
        pathb = strcat({'.\'},{whichfold},{'\RDSO '},{whichfold},{' Tensile 250.is_tens_RawData\Specimen_RawData_'});
        pathc = strcat({'.\'},{whichfold},{'\RDSO '},{whichfold},{' Tensile 500.is_tens_RawData\Specimen_RawData_'});
        path{:,1} = patha{1};
        path{:,2} = pathb{1};
        path{:,3} = pathc{1};
    end
    x = 1;
    path2 = '.csv';
    dataStruct = struct('Load',{},'Extension',{},'Time',{});
    if strcmp(whichfold, 'EPR')
        files = [16 5];
        rates = 2;
    elseif strcmp(whichfold, 'FR')
        files = [8 8 5];
        rates = 3;
    elseif strcmp(whichfold, 'NR')
        files = [8 8 5];
        rates = 3;
    else 
        files = [8 8 5];
        rates = 3;
    end
    dataamount = 0;
    for j = 1:rates
        for file = 1:files(j)
            wholepath = strcat(path(j),int2str(file),path2);
            wholepath = wholepath{1};
            temp = csvread(wholepath,2,0);
            a = size(temp);
            q=find(temp(:,3)==max(temp(:,3)));
            temp(q:a(1),:) = [];
            minload = min(temp(:,3));
            if minload < 0
                temp(:,3) = temp(:,3) - minload;
            end
            dataStruct(file).Time(1) = temp(1,1);%add 0 to the first place
            dataStruct(file).Extension(1) = temp(1,2);
            dataStruct(file).Load(1) = temp(1,3);
            jj = 1;
            for i = 1:1100
                [~,Index(i)] = min(abs(temp(:,2)-i*0.1));
                if dataStruct(file).Load(jj) < temp(Index(i),3)
                    dataStruct(file).Time(jj+1) = temp(Index(i),1);
                    dataStruct(file).Extension(jj+1) = temp(Index(i),2);
                    dataStruct(file).Load(jj+1) = temp(Index(i),3);
                    jj=jj+1;
                end
            end
            for i = 111:220
                [~,Index(i)] = min(abs(temp(:,2)-i));
                if dataStruct(file).Load(jj) < temp(Index(i),3)
                    dataStruct(file).Time(jj+1) = temp(Index(i),1);
                    dataStruct(file).Extension(jj+1) = temp(Index(i),2);
                    dataStruct(file).Load(jj+1) = temp(Index(i),3);
                    jj=jj+1;
                end
            end
            a = size(dataStruct(file).Load);
            amount(x) = a(2);
            x = x+1;
            detaExtension = diff(dataStruct(file).Extension);
            detaTime = diff(dataStruct(file).Time);
            rate = detaExtension./detaTime;
            meanrate(j,file) = mean(rate);
            %save data
            extension = fopen('Extension.txt','a');
            fprintf(extension,'%g\t',dataStruct(file).Extension);
            fclose(extension);
            load = fopen('Load.txt','a');
            fprintf(load,'%g\t',dataStruct(file).Load);
            fclose(load);
            dataamount = dataamount + amount(x-1) ;
            clear temp;
            clear extension;
            clear load;
            clear index;
            clear a;
            clear detaTime;
            clear detaExtension;
            clear rate;
            clear dataStruct;
        end
        mrate = mean(meanrate(j,1:files(j)));
        mrate = 60*mrate * ones(1,dataamount);
        Rate = fopen('Rate.txt','a');
        fprintf(Rate,'%g\t',mrate);
        fclose(Rate);
        clear meanrate
        dataamount = 0;
    end
    Amount = fopen('Amount.txt','a');
    fprintf(Amount,'%g\t',amount);
    fclose(Amount);
end

if switch2
    % load data
    load .\Extension.txt;
    load .\Load.txt;
    load .\Rate.txt;
    save Extension.mat;
    save Rate.mat;
    save Load.mat;
    % p = input; t = output
    p=[Extension;Rate];
    t=Load;
    % calculate the amount of the data
    s = size(Load);% the size is saved as the second parameter in the array.
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
    % add 0 to train set as the load value for negative extension. 
    for i = 1:60
    trainsample.p(2,(sizet+1+51*(i-1)):(sizet+51*i)) =linspace(10*i,10*i,51); % rates of the 0 value are from 10 to 600. 
    trainsample.p(1,sizet+1+51*(i-1):sizet+51*i) = [-50:0]; % extensions of zero value are from -50 to 0 for each rate
    end
    trainsample.t(1,sizet+1:sizet+51*i) = zeros(1,3060); %load = 0

    % build a neural network with 2 hidden layers
    % net = feedforwardnet([12,6]);% 2-12-6-1
    net = feedforwardnet(10);
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

    save('net','net');
    load('net');

    %RMSE
    A = validation.p(1,:);
    B = validation.p(2,:);
    C = validation.t(1,:);
    SimRMSELoad = sim(net,[A;B]);
    MEANrmse= sqrt(mean((SimRMSELoad-C).^2));
    RRMSE = MEANrmse/max(Load);
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
end