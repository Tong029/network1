clc
close all
clear all
index1 = [4,1,4,4,6,6];
index2 = {[2,3,5,9],[10],[2,4,6,9],[2,5,8,9],[2,4,5,6,8,9],[1,2,5,6,7,9]};
j=0;
predicting = {[],[],[]};
save ('predicting','predicting');
for m = 1:6
    for n = 1:10
        k = 0;
        if ismember(n,index2{m})
            k = k+1;
            j = j+1;
            load predicting
            a = predicting{1};
            b = predicting{2};
            c = predicting{3};
            x = index2{m};
            load (strcat(num2str(m),'FRnet',num2str(x(k))));
            tstrate = repmat(0:6:600,100+1,1).';
            tstrate = tstrate.';
            tstrate = tstrate(1:end);% save all the data as an array
            c = [c,tstrate];
            c = c(1:end);
            tstex = repmat(0:100,101,1);
            tstex = tstex.';
            tstex = tstex(1:end);% save all the data as an array
            b = [b,tstex];
            b = b(1:end);
            a = [a,sim(net,[tstex;tstrate])];
            a = a(1:end);
            predicting = {a,b,c}; % simulation 
            %     path = strcat('.\',name{n},'net\',name{n},'predicting');
            save ('predicting','predicting');
        end
    end
end