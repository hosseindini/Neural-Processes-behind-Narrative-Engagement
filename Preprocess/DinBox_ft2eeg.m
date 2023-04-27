function EEG = DinBox_ft2eeg(data,Event)
 
if ~exist('Event','var')
    EEG.event = data.event; 
end

EEG.srate = data.fsample; 
EEG.xmin = data.time{1}(1); 
EEG.xmax = data.time{1}(end);
EEG.chanlocs = data.elec; 

for tr = 1:length(data.trial)
    EEG.data(:,:,tr) = data.trial{tr}; 
end