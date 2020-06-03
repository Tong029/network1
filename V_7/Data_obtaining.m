%get the data of all four types of materials
clc
clear all
close all
%get data
delete *.txt
name = {'EPR','FR','NR','NATR'};
for i = 1:4
    whichfold = name{i};
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
        files = [8 7 6];
        rates = 3;
    else 
        files = [11 5 1];
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
            lload = fopen('Load.txt','a');
            fprintf(lload,'%g\t',dataStruct(file).Load);
            fclose(lload);
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
    if strcmp(whichfold, 'EPR')
        copyfile('Rate.txt','EPRRate.txt');
        copyfile('Load.txt','EPRLoad.txt');
        copyfile('Extension.txt','EPRExtension.txt');
    elseif strcmp(whichfold, 'FR')
        copyfile('Rate.txt','FRRate.txt');
        copyfile('Load.txt','FRLoad.txt');
        copyfile('Extension.txt','FRExtension.txt');
    elseif strcmp(whichfold, 'NR')
        copyfile('Rate.txt','NRRate.txt');
        copyfile('Load.txt','NRLoad.txt');
        copyfile('Extension.txt','NRExtension.txt');
    else 
        copyfile('Rate.txt','NATRRate.txt');
        copyfile('Load.txt','NATRLoad.txt');
        copyfile('Extension.txt','NATRExtension.txt');
    end
    delete Rate.txt
    delete Load.txt
    delete Extension.txt
end
load NATRRate.txt
load NATRLoad.txt
load NATRExtension.txt
load NRRate.txt
load NRLoad.txt
load NRExtension.txt
load FRRate.txt
load FRLoad.txt
load FRExtension.txt
load EPRRate.txt
load EPRLoad.txt
load EPRExtension.txt

save NATRRate.mat
save NATRLoad.mat
save NATRExtension.mat
save NRRate.mat
save NRLoad.mat
save NRExtension.mat
save FRRate.mat
save FRLoad.mat
save FRExtension.mat
save EPRRate.mat
save EPRLoad.mat
save EPRExtension.mat