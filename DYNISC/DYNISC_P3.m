%% Pairwise
% sliding window applied dynamic ISC: (nT-wsize) x ROI
% data saved per participant pair
clc;clear all;close all;

LoadFile_Address = [''];% Load the data which you have from previos step "DYNISC_P2.mat"
savepath = [''];

disp('Pairwise dynamic ISC calculation');
idx = 0;
nR=30;
nsubj=30;
for subj1 = 1:nsubj-1
    load([savepath,'/tcwin',num2str(subj1),'.mat']);
    subj1_data = tcwin;
    for subj2 = subj1+1:nsubj
        disp(['  subj ',num2str(subj1),' & subj ',num2str(subj2)]);
        idx = idx+1;
        if exist([savepath,'/pair',num2str(idx),'.mat'])~=0
        else
            load([savepath,'/tcwin',num2str(subj2),'.mat']);
            subj2_data = tcwin;
            
            time_region_slide = [];
            for time = 1:nT-wsize
                subj1_tmp = squeeze(subj1_data(time,:,:));
                subj2_tmp = squeeze(subj2_data(time,:,:));
                region_slide = [];
                for region = 1:nR
                    region_slide = [region_slide; atanh(corr(subj1_tmp(:,region),subj2_tmp(:,region),'rows','complete'))];
                end
                time_region_slide = [time_region_slide, region_slide];
            end
            time_region_slide = time_region_slide';
            save([savepath,'/pair',num2str(idx),'.mat'],'time_region_slide');
        end
    end
end
