%% DynISC - behavior correlation
% Load every pairwise dynamic ISC
% nPair x (nT-wsize) x nR
clc;clear all;close all

%load sliding_Engagement.mat
%load sliding_surr_Engagement.mat
loadaddress='';%put the address of the folder containing the pairs
wsize = 10;
savepath='';
nsubj = 30;
nR = 30;
nT = 2528;
thres=0.05;


flist = dir([loadaddress,'/pair*.mat']);
pairwisesubj_corr = [];
dynISC = zeros(nsubj*(nsubj-1)/2, nT-wsize, nR);
for listf = 1:length(flist)
    load([loadaddress,'/pair',num2str(listf),'.mat']);
    dynISC(listf, :,:) = time_region_slide;
end


% Per ROI, average pairwise participants' dynamic ISC
mean_dynISC = tanh(squeeze(nanmean(dynISC,1)));

% Correlate with behavioral data, per ROI
region_corr = [];
for region = 1:nR
    region_corr = [region_corr; corr(mean_dynISC(:,region),sliding_Engagement,'rows','complete')];
end
region_corr_actual = region_corr;

% Comparison with null behavior
% load([path,'/data_processed/',story,'/win',num2str(wsize),'/sliding-engagement-surr.mat']);
nsurr = size(sliding_surr_Engagement,2);
disp(['permutation iteration = ',num2str(nsurr)]);
region_corr_surr = zeros(nR,nsurr);
for surr = 1:nsurr
    if mod(surr,100)==0
        disp(['surr ',num2str(surr),' / ',num2str(nsurr)]);
    end
    region_corr = [];
    for region = 1:nR
        region_corr = [region_corr; corr(mean_dynISC(:,region), sliding_surr_Engagement(:,surr),'rows','complete')];
    end
    region_corr_surr(:,surr) = region_corr;
end

%% Statistics
% non-parametric permutation test (two-tailed)
twotailed_pval = [];
for region = 1:nR
    actual = region_corr_actual(region,1);
    if isnan(actual) == 1
        twotailed_pval = [twotailed_pval; NaN];
    else
        surrogate = region_corr_surr(region,:);
        pv = (1+length(find(abs(surrogate)>=abs(actual))))/(length(surrogate)+1);
        twotailed_pval = [twotailed_pval; pv];
    end
end

%% Save
% ROI index, dynamic ISC & behavior correlation r value, p value
results = [];
for roi = 1:nR
    if twotailed_pval(roi) < thres
        results = [results; roi, region_corr_actual(roi), twotailed_pval(roi)];
    end
end
save([savepath,'/ISC_w5.mat'],'results','dynISC');

