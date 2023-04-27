% Ztransforming, Downsampling, and Merging the data of all participants together and save
clc; clear all; close all
LoadFile_Address = [];%load the CSD implemented data
SaveFile_Address = [];
NoSub=32;
EEG=[];
step=200; % 
for Subject_Num=2:NoSub
    if Subject_Num~=13
        load([LoadFile_Address,num2str(Subject_Num),'_CSD'])
        % Normalize
    grot=Data';
    grot=grot-repmat(mean(grot),size(grot,1),1); 
    grot=grot/std(grot(:)); 
    Data = grot';
        % Downsample
        for j=1:size(Data,1)
        for i=1:round(size(Data,2)/step)
        
            temp=Data(j,:);
            Data_DS(j,i)=nanmean(temp(1,i*step-(step-1):i*step));
            [j,Subject_Num]
        end
        end
        
        %merge
        EEG=cat(3,EEG,Data_DS);
        Subject_Num
    end
end
    save([SaveFile_Address,'/EEG.mat'],'EEG','-v7.3');
