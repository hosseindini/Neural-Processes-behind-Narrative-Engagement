% CSD Implementation and save the data
clc; clear all; close all
LoadFile_Address = [];
SaveFile_Address = [];
% load the file called E.mat that is put in the folder together with this
% code
M = ExtractMontage('10-5-System_Mastoids_EGI129.csd',E);  
MapMontage(M);
[G,H] = GetGH(M);
NoSub=32;
EEG=[];

for Subject_Num=2:NoSub
    if Subject_Num~=13
        load([LoadFile_Address,'file name'])
        Data = CSD (data.trial{1,1}, G, H);
        save([SaveFile_Address,num2str(Subject_Num),'_CSD.mat'],'Data','-v7.3');
    Subject_Num
    end
end
