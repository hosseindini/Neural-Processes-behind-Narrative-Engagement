%% == CONG_INCONG_1_PreProc
clc; clear all; close all;
%% ==Directions==
CID1=input('First Participant''s Code number? ');
CID2=input('Last Participant''s Code number? ');
% load the noisy channel list after detecting them(by running corresponding part of this code)
%Load the channel location
SaveFile_Address = [];
LoadFile_Address = [];
%% ==Options==
Temp=[];
saveOption =1; 
plotFiltered = 1; noEpochDisplay = 10; spaceOption = 20; % Plot options 
noEpochDisplay1 = 10;
reref = 0; rerefCh = {'TP8' 'TP7'}; % No masteoids reference
baseline = 0;
BadChannel= 0;
plotNoisy=0;
plotInterpolated=1;
%%
for Subject_Num = CID1:CID2%[2:31]
    cid=num2str(Subject_Num);
    %% ==Load the Data==
    removeCh = {'AUX1' 'AUX2' 'Label1' 'Label2' 'Srate'};   
    eeglab; % Open EEGLAB 
    fileName = strcat(LoadFile_Address,num2str(Subject_Num),'_VIDEO_MEMORY.mat');        
    EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',fileName,'srate',1000,'pnts',0,'xmin',0); 
    [ALLEEG EEG CURRENTSET] = DinBox_eeglabChecklist(ALLEEG, EEG, CURRENTSET);
    %% == Event labels==
    clear Event_Label
    Event_Label=find(EEG.data(33,:)==1);
    %% == Remove unwanted Channels==
    EEG.chanlocs=chanlocsA.chanlocs; 
    EEG = pop_select(EEG,'nochannel',removeCh); % Remove the unwanted channels
    [ALLEEG EEG CURRENTSET] = DinBox_eeglabChecklist(ALLEEG, EEG, CURRENTSET);
        %% ==Filter the Data== 
    filterOrder = 3; lowEdge = 0.1; highEdge = 30; qFactor = 25; % Butterworth zero-phase
    EEG.data = DinBox_bandFilter(EEG.data,EEG.srate,filterOrder,lowEdge,highEdge,qFactor);
    %% ==Re-ref to Mastoeids==
    if reref % Re-ref to mastoeids
        EEG = pop_reref(EEG,rerefCh);
    else % Otherwise remove them
        EEG = pop_select(EEG,'nochannel',rerefCh);
    end
    %% ==Bad Channel Detection==
    if BadChannel
        DinBox_eegPlot(EEG.data, 'srate', EEG.srate,'limits', [EEG.xmin EEG.xmax]*1000,'winlength',noEpochDisplay1,'spacing',spaceOption); % suspected channels
%         pop_prop( EEG, 1, cell2mat(noisyChansPrint.Chan_Num{Subject_Num,1}), NaN,{ 'freqrange' [2 50] });
    end
    %% ==Pick up the video part and align==
    EEG.data= EEG.data(:,Event_Label);
    Temp=[Temp;size(EEG.data,2)];
    if size(EEG.data,2)>505652
        EEG.data=EEG.data(:,1:505652);
    end

%% == Remove Badchannels

%     EEG.data(cell2mat(noisyChansPrint.Chan_Num{Subject_Num,1}),:)=[];
EEG = pop_select(EEG,'nochannel',noisyChansPrint.badChans{1,Subject_Num});

%% Run ICA 
EEG = pop_runica(EEG,'icatype','sobi' ,'extended',1);
EEG = pop_iclabel(EEG, 'Default');
pop_prop( EEG, 0, 1:size(EEG.data,1), NaN, {'freqrange',[2 50] });
close all
%% remove bad components
DinBox_eegPlot(EEG.data, 'srate', EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000,'events', EEG.event,'eloc_file', EEG.chanlocs,'winlength',noEpochDisplay,'spacing',spaceOption);

badComp=[1,2,9,21,23,28,30];
 EEG = pop_subcomp( EEG, badComp, 0);
DinBox_eegPlot(EEG.data, 'srate', EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000,'events', EEG.event,'eloc_file', EEG.chanlocs,'winlength',noEpochDisplay,'spacing',spaceOption);

    %% ==Move to Fieldtrip Format==
    
    data = eeglab2fieldtrip(EEG,'preprocessing');
    data.event = EEG.event;
    data.trial={EEG.data};
    time=0:1/EEG.srate:(505652-1)/EEG.srate; 
%     time(end+1)=506176;
    data.time={time};
    %% Interpolate bad channels
    noisyChansLabel = noisyChansPrint.badChans{Subject_Num}; % Load bad channels (detected manually)
    noisyChansPrint.numberBadChans(Subject_Num) = length(noisyChansLabel);
        
    if ~isempty(noisyChansLabel) % If there is a bad detected channel, interpolate it
        cfg = [];
        cfg.badchannel = noisyChansLabel;
        cfg.method = 'spline';
        data = ft_channelrepair(cfg, data);
        EEG = DinBox_ft2eeg(data);
        EEG.event=[];
    end

%% Re-reference
         cfg = []; cfg.reref = 'yes'; cfg.refchannel = 'all';
         data_reref = ft_preprocessing(cfg, data);
         data.trial = data_reref.trial;
             EEG1 = DinBox_ft2eeg(data);
             EEG1.event=[];
             DinBox_eegPlot(EEG1.data, 'srate', EEG1.srate, 'limits', [EEG1.xmin EEG1.xmax]*1000,...
                 'events', EEG1.event,'eloc_file', chanlocs,'winlength',noEpochDisplay,'spacing',spaceOption);
             figure;
             pxx=DinBox_PlotPSD(data);


        %% ==Save the data==
            save([SaveFile_Address,'/',cid,'_VIDEO_MEMORY'],'data');
close all
end
