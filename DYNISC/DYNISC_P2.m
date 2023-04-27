clc;clear all;close all;
%Load the data after normalization
savepath = [''];
EEG=permute(EEG,[3,1,2]);
wsize = 10;
thres = 0.05;
nsubj = size(EEG,1);
nT = size(EEG,3);
nR = size(EEG,2);
sigma=3;

 for subj = 1:nsubj
    disp(['  subj ',num2str(subj),' / ',num2str(nsubj)]);
    ts = squeeze(BOLD(subj,:,:)); ts = ts';
    
    if any(isnan(ts(:,1)))
        nT_subj = length(find(~isnan(ts(:,1))));
        nanid = find(isnan(ts(:,1)));
        disp('  ******* due to fMRI timeseries having NaN, temporarily erase NaN from timeseries');
        ts = ts(find(~isnan(ts(:,1))),:);
    end
    
    % compute sliding window
    nT_subj = size(ts,1);
    nR = size(ts,2);
    
    if mod(nT_subj,2) ~= 0
        m = ceil(nT_subj/2);
        x = 0:nT_subj;
    else
        m = nT_subj/2;
        x = 0:nT_subj-1;
    end
    w = round(wsize/2);
    gw = exp(- ((x-m).^2) / (2*sigma*sigma))';
    b = zeros(nT_subj,1); b((m-w+1):(m+w)) = 1;
    c = conv(gw, b); c = c/max(c); c = c(m+1:end-m+1);
    c = c(1:nT_subj);
    
    % Dynamic connectivity
    A = repmat(c,1,nR);
    Nwin = nT_subj - wsize;
    FNCdyn = zeros(Nwin, nR*(nR - 1)/2);
    
    % Apply circular shift to time series
    tcwin = zeros(Nwin, nT_subj, nR); %% total of Nwin windos and segment data within each window and put it in a 3d mat
    for ii = 1:Nwin
        % slide gaussian centered on [1+wsize/2, nT_subj-wsize/2]
        Ashift = circshift(A, round(-nT_subj/2) + round(wsize/2) + ii);
        
        % when using "circshift", prevent spillover of the gaussian
        % to either the beginning or an end of the timeseries
        if ii<floor(Nwin/2) & Ashift(end,1)~=0
            Ashift(ceil(Nwin/2):end,:) = 0;
            Ashift = Ashift.*(sum(A(:,1))/sum(Ashift(1:floor(Nwin/2),1)));
        elseif ii>floor(Nwin/2) & Ashift(1,1)~=0
            Ashift(1:floor(Nwin/2),:) = 0;
            Ashift = Ashift.*(sum(A(:,1))/sum(Ashift(ceil(Nwin/2):end,1)));
        end
        
        % apply gaussian weighted sliding window of the timeseries
        tcwin(ii, :, :) = squeeze(ts).*Ashift;
    end
    
    if nT_subj~=nT
        disp('  ******* add NaN dynFC at the end');
        tcwin = cat(1, tcwin, zeros(nT-nT_subj, size(tcwin,2), size(tcwin,3))*NaN);
        tcwin = cat(2, tcwin, zeros(size(tcwin,1), nT-nT_subj, size(tcwin,3))*NaN);
    end
    
    save([savepath,'/tcwin',num2str(subj),'.mat'],'tcwin','-v7.3');
end

