function data = DinBox_bandFilter(input,Fs,order,lowEdge,highEdge,qualityFactor)

% [ch,time] = size(data); 
data = double(input); 

if ~isempty(qualityFactor)
    wo = 50/(Fs/2); 
    bw = wo/qualityFactor;
    [f,e] = iirnotch(wo,bw);  
    for ch = 1:size(data,1)  
         data(ch,:) = filtfilt(f,e,data(ch,:));
    end
end

if ~isempty(lowEdge) 
    [b,a] = butter(order,lowEdge/(Fs/2),'high'); 
    for ch = 1:size(data,1)  
         data(ch,:) = filtfilt(b,a,data(ch,:));
    end
end

if ~isempty(highEdge)
    [d,c] = butter(order,highEdge/(Fs/2),'low'); 
    for ch = 1:size(data,1)  
         data(ch,:) = filtfilt(d,c,data(ch,:));
    end
end

