%% given a subset of population, under certain condition, see the capacity of orientation decoding of neurons

%% clear history variables
clearvars;
clear global;
clc; close all;

%% raw data pathes
% data_root = 'H:/2023/Research/CFS/';
data_root = '/Volumes/TOSHIBA EXT/Research/CFS/';
M180627_V1_site1 = [data_root 'data/M180627_V1_site1/']; % V2
M180627_V1_site3 = [data_root 'data/M180627_V1_site3/']; % V2
M180627_V1_site4 = [data_root 'data/M180627_V1_site4/'];
M180627_V1_site6 = [data_root 'data/M180627_V1_site6/'];
M1807049_V1_site1 = [data_root 'data/M1807049_V1_site1/']; % useless
M1807049_V1_site5 = [data_root 'data/M1807049_V1_site5/']; % useless
M1807049_V1_site6 = [data_root 'data/M1807049_V1_site6/'];
M1807049_V1_site1_05 = [data_root 'data/M1807049_V1_site1_05/'];

dataPathList = {M180627_V1_site1,M180627_V1_site3,M180627_V1_site4,M180627_V1_site6,M1807049_V1_site1,M1807049_V1_site5,M1807049_V1_site6,M1807049_V1_site1_05};
dataNameList = {'M180627_V1_site1','M180627_V1_site2','M180627_V1_site3','M180627_V1_site4','M1807049_V1_site1','M1807049_V1_site5','M1807049_V1_site6','M1807049_V1_site1_05'};

fig = figure(1);
tiledlayout(1,1);
set(fig, 'Position', [100, 300, 380, 350])
iFig = 0;
FIratio_cfs_mono_15 = [];
DPratio_cfs_mono_15 = [];
titlenames = {'MA1-contra','MA1-ipsi', 'MA2-contra','MA2-ipsi','MB1-contra','MB1-ipsi','MB2-contra','MB2-ipsi'};

% define colors
colorlist = [0, 114, 178; 0, 168, 115; 213, 94, 0; 230, 159, 0;204, 121, 167;86, 180, 233;128, 0, 128;...   % Deep Purple
             128, 128, 0]./255;

% load data
% acc_mono_all = [];
% acc_cfs_all = [];
hold on
iFig = 0;
p = [];
means_all = [];
ses_all = [];
for iPath = [3 4 7 8]
    iFig = iFig + 1;
    % load necessary datum
    load([dataPathList{iPath} 'ODI.mat'], "ODI");
    load([dataPathList{iPath} 'G4_PeakOriListTotal_base.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_base.mat']);
    load([dataPathList{iPath} 'G4_PeakOriListTotal_ipis.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_ipis.mat']);
    load([dataPathList{iPath} 'G4_PeakOriListTotal_contra.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_contra.mat']);
    load([dataPathList{iPath} 'G4_RspMeanTrialStdSeListTotal_base.mat']);
    load([dataPathList{iPath} 'G4_RspAvgOFFListTotal_base.mat']);
    load([dataPathList{iPath} 'OvOSVM_acc.mat'], "Acc_list");
    % {bino_list, mono_contra_list, mono_ipis_list, cfs_contra_list,cfs_ipis_list};

    Acc_list = Acc_list(2:end);

    %% calculate mean and se for 10 folds CV
    % Assuming Acc_list is a cell array where each cell contains a numerical array
    means = cellfun(@mean, Acc_list);  % Compute mean for each array
    means_all = [means_all; means];
    ns    = cellfun(@numel, Acc_list);                % sample size per cell
    sd_origs   = cellfun(@(x) std(x, 0), Acc_list);        % unbiased SD (N-1)
    ses   = sd_origs ./ sqrt(ns);                          % standard error
    ses_all = [ses_all; ses];
    sds = 1.96 .* ses;                           % half-width of 95% CI
    
    % contralateral
%     p(iFig) = errorbar(means(2),means(4),sds(4)/2,sds(4)/2,sds(2)/2,sds(2)/2,'o',...
%         'MarkerFaceColor',colorlist(iFig,:), 'MarkerEdgeColor',colorlist(iFig,:),...
%         'Color', colorlist(iFig,:), 'MarkerSize', 8, 'LineWidth', 1.5);
%     g = errorbar(means(3),means(5),sds(5)/2,sds(5)/2,sds(3)/2,sds(3)/2,'d',...
%         'MarkerFaceColor',colorlist(iFig,:), 'MarkerEdgeColor',colorlist(iFig,:),...
%         'Color', colorlist(iFig,:), 'MarkerSize', 8, 'LineWidth', 1.5);

    % contralateral
    p = [p errorbar(means(1),means(3),sds(3),sds(3),sds(1),sds(1),'o',...
        'MarkerFaceColor',colorlist(iFig,:), 'MarkerEdgeColor',colorlist(iFig,:),...
        'Color', colorlist(iFig,:), 'MarkerSize', 9, 'LineWidth', 1.5)];
    
    % Manually add dashed vertical error bars
    plot([means(2), means(2)], [means(4) - sds(4), means(4) + sds(4)], '--', ...
        'Color', colorlist(iFig,:), 'LineWidth', 1.5);
    
    % Manually add dashed horizontal error bars
    plot([means(2) - sds(2), means(2) + sds(2)], [means(4), means(4)], '--', ...
        'Color', colorlist(iFig,:), 'LineWidth', 1.5);

    % Ipsilateral (Manually Adding Dashed Error Bars)
    % Plot marker separately
    p = [p errorbar(means(2),means(4),sds(4),sds(4),sds(2),sds(2),'o',...
        'MarkerFaceColor',[1 1 1], 'MarkerEdgeColor',colorlist(iFig,:),...
        'Color', 'none', 'MarkerSize', 9, 'LineWidth', 1.5, 'LineStyle','none', 'CapSize', 10)];

end
plot(linspace(1/12,1,100), linspace(1/12,1,100), '--k', 'LineWidth',2)
ylim([1/12, 1])
yticks(0.2:0.2:1)
xlim([1/12 1])
xticks(0.2:0.2:1)
ax = gca;                      % get current axes handle
ax.TickLength = [0.03 0.02];   % [major minor] tick length, in relative units
hold off
xlabel("Baseline Acc")
ylabel("CFS Acc")
legend(p, titlenames, 'interpreter', 'none', 'Location', 'Southeast', 'box', 'off')
set(gca, 'Box', 'off', 'LineWidth', 2, 'FontSize', 16);

% print([data_root 'results/svm_12wayacc_V2'], '-depsc', '-painters'); % for vector graphics