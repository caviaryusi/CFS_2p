%% calculate Fisher information of each neuron based on its orientation response and variance tuning

%% clear history variables
clearvars;
clear global;
clc; close all;

%% raw data pathes
data_root = '/Volumes/TOSHIBA EXT/Research/CFS/';
MA_1 = [data_root 'data/Data_repository/MA_1/'];
MA_2 = [data_root 'data/Data_repository/MA_2/'];
MB_1 = [data_root 'data/Data_repository/MB_1/'];
MB_2 = [data_root 'data/Data_repository/MB_2/'];
MA_3 = [data_root 'data/Data_repository/MA_3/'];
MA_4 = [data_root 'data/Data_repository/MA_4/'];

dataPathList = {MA_1, MA_2, MB_1, MB_2, MA_3, MA_4};
dataNameList = {'MA_1', 'MA_2', 'MB_1', 'MB_2', 'MA_3', 'MA_4'};

fig = figure(1);
tiledlayout(3,3);
set(fig, 'Position', [100, 300, 1000, 900])
iFig = 0;
FIratio_cfs_mono_15 = [];
DPratio_cfs_mono_15 = [];
titlenames = {'MA_V2_1','MA_V2_2', 'MA_V1_1','MA_V1_2','MB_V1','MB_V1_2'};

for iPath = 2
    iFig = iFig+1;
    % load necessary datum
    load([dataPathList{iPath} 'G4_PeakOriListTotal_base.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_base.mat']);
    load([dataPathList{iPath} 'G4_PeakOriListTotal_ipis.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_ipis.mat']);
    load([dataPathList{iPath} 'G4_PeakOriListTotal_contra.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_contra.mat']);
    load([dataPathList{iPath} 'G4_RspMeanTrialStdSeListTotal_base.mat']);
    load([dataPathList{iPath} 'G4_RspMeanTrialStdSeListTotal_base.mat']);

    % for each neuron, each condition, select its ori tuning under most
    % preferred sf, and align most preferred ori to the 1st element
    num_oris = 12;
    [bino_list, mono_contra_list, mono_ipis_list, cfs_contra_list, cfs_ipis_list] = deal(zeros(size(G4_RspMeanTrialStdSeListTotal_base,1),num_oris));
    [bino_std_list, mono_contra_std_list, mono_ipis_std_list, cfs_contra_std_list, cfs_ipis_std_list] = deal(zeros(size(G4_RspMeanTrialStdSeListTotal_base,1),num_oris));
    [noise_contra_list, noise_ipis_list] = deal(zeros(size(G4_RspMeanTrialStdSeListTotal_base,1), num_oris));
    for ci = 1:size(G4_RspMeanTrialStdSeListTotal_base,1)
        sflist = [G4_PeakSfListTotal_contra(ci) G4_PeakSfListTotal_ipis(ci) G4_PeakSfListTotal_base(ci)];
        orilist = [G4_PeakOriListTotal_contra(ci) G4_PeakOriListTotal_ipis(ci) G4_PeakOriListTotal_base(ci)];

        bino_idx = 96+(sflist(3)-1)*12+1:96+(sflist(3)-1)*12+num_oris; % peak sf
        mono_contra_idx = 48+(sflist(1)-1)*12+1:48+(sflist(1)-1)*12+num_oris;
        mono_ipis_idx = 72+(sflist(2)-1)*12+1:72+(sflist(2)-1)*12+num_oris;
        cfs_contra_idx = 0+(sflist(1)-1)*12+1:0+(sflist(1)-1)*12+num_oris;
        cfs_ipis_idx = 24+(sflist(2)-1)*12+1:24+(sflist(2)-1)*12+num_oris;
        noise_contra_idx = 121;
        noise_ipis_idx = 122;

        bino_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,bino_idx,1),12-orilist(3)+1);
        mono_contra_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,mono_contra_idx,1),12-orilist(1)+1);
        mono_ipis_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,mono_ipis_idx,1),12-orilist(2)+1);
        cfs_contra_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,cfs_contra_idx,1),12-orilist(1)+1);
        cfs_ipis_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,cfs_ipis_idx,1),12-orilist(2)+1);

        bino_std_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,bino_idx,3),12-orilist(3)+1);
        mono_contra_std_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,mono_contra_idx,3),12-orilist(1)+1);
        mono_ipis_std_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,mono_ipis_idx,3),12-orilist(2)+1);
        cfs_contra_std_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,cfs_contra_idx,3),12-orilist(1)+1);
        cfs_ipis_std_list(ci,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,cfs_ipis_idx,3),12-orilist(2)+1);
    end

    %% for each cell and each condition, calculate the fisher information
    Rsp_lists = {bino_list, mono_ipis_list, mono_contra_list, cfs_ipis_list, cfs_contra_list}; % list to calculate
    Std_lists = {bino_std_list, mono_ipis_std_list, mono_contra_std_list, cfs_ipis_std_list, cfs_contra_std_list}; % list to calculate
    Name_lists = {'bino', 'mono_ipis', 'mono_contra','cfs_ipis','cfs_contra'};

    for iList = 1:length(Rsp_lists)
        Rsp_list = circshift(Rsp_lists{iList}, 6, 2);
        Std_list = circshift(Std_lists{iList}, 6, 2).^2;
        FI_list = nan(size(Rsp_list,1),100);
        y_hat = nan(size(Rsp_list,1),100);
        y_var = nan(size(Rsp_list,1),100);
        Rsp_fit_Rsquare = nan(size(Rsp_list,1),1);
        Var_fit_Rsquare = nan(size(Rsp_list,1),1);
        for i = 1:size(Rsp_list,1) % loop over cell
            xData = linspace(-90, 75, 100);
            [m,n] = fitGaussian([-90:15:75]',Rsp_list(i,:)');
            y_hat(i,:) = feval(m, xData);
            Rsp_fit_Rsquare(i) = n.rsquare;
            [m,n] = fitGaussian([-90:15:75]',Std_list(i,:)');
            y_var(i,:) = feval(m, xData);
            Var_fit_Rsquare = nan(size(Rsp_list,1),1);
            theta = linspace(-90, 75, length(y_hat(i,:)));
            dr_dtheta(i,:) = gradient(y_hat(i,:), theta);
            %             I_theta = (dr_dtheta(i,:) .^ 2);
            I_theta = (dr_dtheta(i,:) .^ 2) ./ ((y_var(i,:)));
            FI_list(i,:) = I_theta;
        end
        save([dataPathList{iPath} 'FI_' Name_lists{iList} '.mat'], "FI_list",'Rsp_fit_Rsquare','Var_fit_Rsquare',"dr_dtheta","y_hat","y_var");
    end

end