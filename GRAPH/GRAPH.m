clear;clc;close all;
%load the data from output of DYNFC.mat
savepath='';
wsize=25;
nsubj=size(dynFeat,1);
nWin=size(dynFeat,3);
nR=30;
ST=zeros(nsubj,30,nWin);
CC=zeros(nsubj,30,nWin);
BC=zeros(nsubj,30,nWin);

for i=1:nsubj
    for j=1:nWin
        temp=squeeze(dynFeat(i,:,j));
        matrix=vec2mat(temp,30);
        
        [St]=fastfc_strength_wu(matrix);
        [C]=fastfc_cluster_coef_bu(matrix);
        W=(matrix.^-1);
        [~,~,B]=fastfc_betweenness_cent_w(W);
        
        if mean(mean(isnan(St)))~=0
            display('ST of',[num2str(i) num2str(j),'is NaN'])
        end
        
        if mean(mean(isnan(C)))~=0
            display('C of',[num2str(i) num2str(j),'is NaN'])
        end
        
        if mean(mean(isnan(B)))~=0
            display('B of',[num2str(i) num2str(j),'is NaN'])
        end        
        ST(i,:,j)=St;
        CC(i,:,j)=C;
        BC(i,:,j)=B;
        
        temp=[];
        matrix=[];
        
    end
    i
end
    save([savepath,'/ST',num2str(wsize),'.mat'],'ST','-v7.3');
    save([savepath,'/CC',num2str(wsize),'.mat'],'CC','-v7.3');
    save([savepath,'/BC',num2str(wsize),'.mat'],'BC','-v7.3');
