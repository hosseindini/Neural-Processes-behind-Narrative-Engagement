% This code is inspired from Hayoung Song (hyssong@uchicago.edu) but
% adjusted for this study


clc; clear all; close all;
% Load the data obtained from output of implementing CSD
path = '';

wsize = 15;%you can put mutiple windows like:[5 10 15 20 ...]
sigma=3;
EEG=permute(EEG,[3,1,2]);
nsubj = size(EEG,1);
nT = size(EEG,3);
nR = size(EEG,2);


dynFeat_win = {};
for ws = 1:length(wsize)
    dynFeat = [];
    disp(' ');
    disp(['    wsize         = ',num2str(wsize(ws))]);
    disp(['    stepsize      = 1']);
    disp(['    tapered sigma = ',num2str(sigma)]);
    disp(' ');
    for subj = 1:nsubj
        disp(['    subj ',num2str(subj),' / ',num2str(nsubj)]);
        ts = squeeze(EEG(subj,:,:)); ts=ts';
        
        if any(isnan(ts(:,1)))
            nT_subj = length(find(~isnan(ts(:,1))));
            nanid = find(isnan(ts(:,1)));
            disp('******* include missing values in the timeseries');
            ts = ts(find(~isnan(ts(:,1))),:);
        else
            nT_subj = nT;
        end
        
        % Normalize within region, then divide it by the total stddev

        % compute sliding window
        if size(ts,1)~= nT_subj
            error('check time series column/row');
        end
        if mod(nT_subj,2) ~= 0
            m = ceil(nT_subj/2);
            x = 0:nT_subj;
        else
            m = nT_subj/2;
            x = 0:nT_subj-1;
        end
        w = round(wsize(ws)/2);
        gw = exp(- ((x-m).^2) / (2*sigma*sigma))';
        b = zeros(nT_subj,1); b((m-w+1):(m+w)) = 1;
        c = conv(gw, b); c = c/max(c); c = c(m+1:end-m+1);
        c = c(1:nT_subj);
        
        % Dynamic connectivity
        A = repmat(c,1,nR);
        Nwin = nT_subj - wsize(ws);
        FNCdyn = zeros(Nwin, nR*(nR - 1)/2);
        
        % Apply circular shift to time series
        tcwin = zeros(Nwin, nT_subj, nR);
        for ii = 1:Nwin
            % slide gaussian centered on [1+wsize/2, nT_subj-wsize/2]
            Ashift = circshift(A, round(-nT_subj/2) + round(wsize(ws)/2) + ii);
            
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
        
        % Fisher's r-to-z transformed dynamic functional connectivity matrix
        tapered_pearsonz = zeros(Nwin,nR,nR);
        for ii = 1:Nwin
            tmp = atanh(corr(squeeze(tcwin(ii,:,:))));
            for i = 1:nR; tmp(i,i) = 0; end
            tapered_pearsonz(ii,:,:) = tmp;
        end
        
        if nT_subj~=nT
            disp('******* add NaN dynFC at the end');
            tapered_pearsonz = cat(1,tapered_pearsonz,zeros(length(nanid),nR,nR)*NaN);
        end
        
        % to reduce data size, reduce into feature dimension
        dynft = [];
        for tm = 1:(nT-wsize(ws))
            tmp = squeeze(tapered_pearsonz(tm,:,:));
            feat = [];
            for i1 = 1:nR-1
                for i2 = i1+1:nR
                    feat = [feat; tmp(i1,i2)];
                end
            end
            dynft = [dynft, feat];
        end
        dynFeat = cat(3, dynFeat, dynft);
    end
    
    % dynamic brain connectivity "feature": (nsubj, nRx(nR-1)/2, nT-wsize)
    dynFeat = permute(dynFeat, [3,1,2]);
    
    disp('Saving .....');

    save([path,'/dynFeat',num2str(wsize(ws))],'dynFeat');
    disp('Finished!');
    
    dynFeat_win{ws,1} = dynFeat;
end
