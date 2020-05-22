clc
clear all
close all
delete *.txt

path{:,1} = '.\NR\RDSO NR Tensile 50.is_tens_RawData\Specimen_RawData_';
path{:,2} = '.\NR\RDSO NR Tensile 250.is_tens_RawData\Specimen_RawData_';
path{:,3} = '.\NR\RDSO NR Tensile 500.is_tens_RawData\Specimen_RawData_';

x = 1;

path2 = '.csv';
dataStruct = struct('Load',{},'Extension',{},'Time',{});
% files = input('');
files = [8 7 6];
rates = 3;
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

%   		maxExtension = round(max(temp(:,2)));
		dataStruct(file).Time(1) = temp(1,1);%add 0 to the first place
		dataStruct(file).Extension(1) = temp(1,2);
		dataStruct(file).Load(1) = temp(1,3);
        jj = 1;
		for i = 1:500
			[~,Index(i)] = min(abs(temp(:,2)-i*0.1));
            if dataStruct(file).Load(jj) < temp(Index(i),3)
                dataStruct(file).Time(jj+1) = temp(Index(i),1);
                dataStruct(file).Extension(jj+1) = temp(Index(i),2);
                dataStruct(file).Load(jj+1) = temp(Index(i),3);
                jj=jj+1;
            end
        end
        for i = 51:100
			[~,Index(i)] = min(abs(temp(:,2)-i));
            if dataStruct(file).Load(jj) < temp(Index(i),3)
                dataStruct(file).Time(jj+1) = temp(Index(i),1);
                dataStruct(file).Extension(jj+1) = temp(Index(i),2);
                dataStruct(file).Load(jj+1) = temp(Index(i),3);
                jj=jj+1;
            end
        end
%         dataStruct(file).Load = smoothdata(dataStruct(file).Load);
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

%         plot(dataStruct(file).Extension,dataStruct(file).Load);

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

copyfile('Rate.txt','ERRORRate.txt');
copyfile('Load.txt','ERRORLoad.txt');
copyfile('Extension.txt','ERRORExtension.txt');
Amount = fopen('Amount.txt','a');
fprintf(Amount,'%g\t',amount);
fclose(Amount);

% % add 0 to negative extension value
% n_extension = [];
% n_rate = [];
% for i = 1:60
% n_raten = linspace(10*i,10*i,51);
% n_rate = [n_rate,n_raten];
% n_extension = [n_extension,-50:0];
% end
% n_load = zeros(1,3060);
% 
% extension = fopen('Extension.txt','a');
% fprintf(extension,'%g\t',n_extension);
% fclose(extension);
% 
% load = fopen('Load.txt','a');
% fprintf(load,'%g\t',n_load);
% fclose(load);
% 
% Rate = fopen('Rate.txt','a');
% fprintf(Rate,'%g\t',n_rate);
% fclose(Rate);