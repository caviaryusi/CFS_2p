%% visualization of Fisher information, run FisherInformation.m first

%% clear history variables
clearvars;
clear all;
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
tiledlayout(1,3);
set(fig, 'Position', [100, 300, 1000, 300])
iFig = 0;
FIratio_cfs_mono_15 = [];
DPratio_cfs_mono_15 = [];
titlenames = {'MA', 'MB'};

pooled_list = {[1 2], [3 4], [5 6]};

for iPool = 1:2

    iFig = iFig+1;

    % concatenate data from FOVs in the same pool
    FI_bino_all = [];
    FI_mono_ipis_all = [];
    FI_mono_contra_all = [];
    FI_cfs_ipis_all = [];
    FI_cfs_contra_all = [];
    Y1_AnovaListTotal_base_all = [];
    Y1_AnovaListTotal_ipis_all = [];
    Y1_AnovaListTotal_contra_all = [];
    for iPath = pooled_list{iPool}
        % load necessary datum
        load([dataPathList{iPath} 'Y1_AnovaListTotal_base.mat'], "Y1_AnovaListTotal_base");
        load([dataPathList{iPath} 'Y1_AnovaListTotal_contra.mat'], "Y1_AnovaListTotal_contra");
        load([dataPathList{iPath} 'Y1_AnovaListTotal_ipis.mat'], "Y1_AnovaListTotal_ipis");
    
        %% for each cell and each condition, load the fisher information
        Name_lists = {'bino', 'mono_ipis', 'mono_contra','cfs_ipis','cfs_contra'};
    
        %% visualization of FI
        % load necessary data
        for iList = 1:length(Name_lists)
            load([dataPathList{iPath} 'FI_' Name_lists{iList} '.mat'], "FI_list",'Rsp_fit_Rsquare','Var_fit_Rsquare',"dr_dtheta","y_hat","y_var");
            eval(['FI_' Name_lists{iList}  ' = FI_list;']);
            eval(['Rsp_fit_Rsquare_' Name_lists{iList} ' = Rsp_fit_Rsquare;'])
            eval(['Var_fit_Rsquare_' Name_lists{iList} ' = Var_fit_Rsquare;'])
        end
    
        % concatenate data from FOVs in the same pool
        FI_bino_all = [FI_bino_all; FI_bino];
        FI_mono_ipis_all = [FI_mono_ipis_all; FI_mono_ipis];
        FI_mono_contra_all = [FI_mono_contra_all; FI_mono_contra];
        FI_cfs_ipis_all = [FI_cfs_ipis_all; FI_cfs_ipis];
        FI_cfs_contra_all = [FI_cfs_contra_all; FI_cfs_contra];
        Y1_AnovaListTotal_base_all = [Y1_AnovaListTotal_base_all Y1_AnovaListTotal_base];
        Y1_AnovaListTotal_ipis_all = [Y1_AnovaListTotal_ipis_all Y1_AnovaListTotal_ipis];
        Y1_AnovaListTotal_contra_all = [Y1_AnovaListTotal_contra_all Y1_AnovaListTotal_contra];
    end

    % rename _all variable into normal variable
    FI_bino_all = FI_bino;
    FI_mono_ipis = FI_mono_ipis_all;
    FI_mono_contra = FI_mono_contra_all;
    FI_cfs_ipis = FI_cfs_ipis_all;
    FI_cfs_contra = FI_cfs_contra_all;
    Y1_AnovaListTotal_base = Y1_AnovaListTotal_base_all;
    Y1_AnovaListTotal_ipis = Y1_AnovaListTotal_ipis_all;
    Y1_AnovaListTotal_contra = Y1_AnovaListTotal_contra_all;

    % pick neurons
    linestoplot = {FI_bino, FI_mono_contra, FI_mono_ipis,FI_cfs_contra, FI_cfs_ipis};
    legends = {'bino','mono_contra','mono_ipis','cfs_contra','cfs_ipis'};
    %     Rsquare_idx = find((Rsp_fit_Rsquare_bino'>.5 | Rsp_fit_Rsquare_mono_ipis'>.5 | Rsp_fit_Rsquare_mono_contra'>.5 ...
    %         | Rsp_fit_Rsquare_cfs_ipis'>.5 | Rsp_fit_Rsquare_cfs_contra'>.5 ...
    %         | Var_fit_Rsquare_mono_ipis'>.5 | Var_fit_Rsquare_mono_contra'>.5 ...
    %         | Var_fit_Rsquare_cfs_ipis'>.5 | Var_fit_Rsquare_cfs_contra'>.5));
    %     neuron_idx = {find((ODI<-0.2)), find(ODI>=-0.2 & ODI<-0.15), find(ODI>=-0.15 & ODI<-0.1), find(ODI>=-0.1 & ODI<-0.05), find(ODI>=-0.05 & ODI<0), find(ODI>=0 & ODI<0.05), find(ODI>=0.05 & ODI<0.1), find(ODI>=0.1 & ODI<0.15), find(ODI>=0.15 & ODI<0.2), find((ODI>=0.2))};
    %     neuron_idx = {find((ODI<-0.2)), find(ODI>=-0.2 & ODI<-0.1), find(ODI>=-0.1 & ODI<0), find(ODI>=0 & ODI<0.1), find(ODI>=0.1 & ODI<0.2), find((ODI>=0.2))};
    %     neuron_idx = {find((ODI<-0.2)), find(ODI>=-0.2 & ODI<-0.05), find(ODI>=-0.05 & ODI<0.05), find(ODI>=0.05 & ODI<0.2), find((ODI>=0.2))};
    %     neuron_idx = {find( ODI<-0.2 & (Y1_AnovaListTotal_base'<.01 | Y1_AnovaListTotal_contra'<.01 | Y1_AnovaListTotal_ipis'<.01)), ...
    %         find(abs(ODI)<=0.2 & (Y1_AnovaListTotal_base'<.01 | Y1_AnovaListTotal_contra'<.01 | Y1_AnovaListTotal_ipis'<.01)), ...
    %         find(ODI>0.2 & (Y1_AnovaListTotal_base'<.01 | Y1_AnovaListTotal_contra'<.01 | Y1_AnovaListTotal_ipis'<.01))};
    neuron_idx_all = find((Y1_AnovaListTotal_base'<.01 | Y1_AnovaListTotal_contra'<.01 | Y1_AnovaListTotal_ipis'<.01)); % all<0.01
    num_of_lines = 3;
    colorlist = turbo(num_of_lines+2);
    colorlist = colorlist(2:size(colorlist,1), :);
    %     colorlist = [linspace(216,0,num_of_lines)' linspace(33,0,num_of_lines)' linspace(28,0,num_of_lines)']/255;
    fitparams = zeros(num_of_lines,9);

    % outliner
    FI_mono_list = [FI_mono_ipis(neuron_idx_all,:); FI_mono_contra(neuron_idx_all,:)];
    FI_cfs_list = [FI_cfs_ipis(neuron_idx_all,:); FI_cfs_contra(neuron_idx_all,:)];
    % mono
    FI_mono_exclusion = FI_mono_list;
    [rows, cols] = size(FI_mono_exclusion);
    for col = 1:cols
        colMean = mean(FI_mono_exclusion(:, col));
        colStd = std(FI_mono_exclusion(:, col));
        outliers = abs(FI_mono_exclusion(:, col) - colMean) > 3 * colStd;
        FI_mono_exclusion(outliers, col) = nan;
    end
    % cfs
    FI_cfs_exclusion = FI_cfs_list;
    [rows, cols] = size(FI_cfs_exclusion);
    for col = 1:cols
        colMean = mean(FI_cfs_exclusion(:, col));
        colStd = std(FI_cfs_exclusion(:, col));
        outliers = abs(FI_cfs_exclusion(:, col) - colMean) > 3 * colStd;
        FI_cfs_exclusion(outliers, col) = nan;
    end

    % cumsum
    range_list = 1:50;
    mean_FI = nan(2, length(range_list));
    mean_DP = nan(2, length(range_list));
    index_list = linspace(-90,75,100);
    for irange = range_list
        index_temp = find(abs(index_list-0)<irange);
        mean_FI(1, irange) = mean(mean(FI_mono_exclusion(:,index_temp), 'omitnan'), 'omitnan'); % mono
        mean_FI(2, irange) = mean(mean(FI_cfs_exclusion(:,index_temp), 'omitnan'), 'omitnan');% CFS
        mean_DP(1, irange) = mean(sqrt(mean(FI_mono_exclusion(:,index_temp), 'omitnan')), 'omitnan'); % mono
        mean_DP(2, irange) = mean(sqrt(mean(FI_cfs_exclusion(:,index_temp), 'omitnan')), 'omitnan'); % CFS
    end

    % have a glance at the whole neuron population
    nexttile
    hold on
    tempx = [linspace(-90,75,100) fliplr(linspace(-90,75,100))];
    meanvalue = mean(FI_mono_exclusion, 'omitnan');
    sevalue = std(FI_mono_exclusion, 'omitnan')./sqrt(sum(~isnan(FI_mono_exclusion), 1));
    civalue = 1*sevalue;
    tempy = [meanvalue + civalue fliplr(meanvalue - civalue)];
    fill(tempx, tempy, [216 33 28]/255, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    p(1) = plot(linspace(-90,75,100), mean(FI_mono_exclusion, 'omitnan'),'LineWidth',1, 'Color', [216 33 28]/255);
    tempx = [linspace(-90,75,100) fliplr(linspace(-90,75,100))];
    meanvalue = mean(FI_cfs_exclusion, 'omitnan');
    sevalue = std(FI_cfs_exclusion, 'omitnan')./sqrt(sum(~isnan(FI_cfs_exclusion), 1));
    civalue = 1*sevalue;
    tempy = [meanvalue + civalue fliplr(meanvalue - civalue)];
    fill(tempx, tempy, [41 155 207]/255, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    p(2) = plot(linspace(-90,75,100), mean(FI_cfs_exclusion, 'omitnan'),'LineWidth',1,'Color', [41 155 207]/255);
    legend(p, {'w/o CFS','w/ CFS'}, 'fontsize', 12,'Box','off')
    xlabel("Relative Orientation")
    xticks([-90 -45 0 45 90])
    ylim([0 0.09])
    yticks(0:0.02:0.09)
    ylabel("Fisher Information")
    hold off
    ax = gca;
    title(titlenames{iFig}, "interpreter", 'none')
    set(ax, 'Box', 'off', 'LineWidth', 1.5, 'FontSize', 12);


    % change over +-15 deg
    FIratio_cfs_mono_15 = [FIratio_cfs_mono_15 mean_FI(2, 15)/mean_FI(1, 15)];
    DPratio_cfs_mono_15 = [DPratio_cfs_mono_15 mean_DP(2, 15)/mean_DP(1, 15)];

end

% proportion
colorlist = [0, 114, 178; 0, 168, 115; 213, 94, 0; 230, 159, 0]./255;
nexttile % bar plot summarizing
hold on
for itemp = 1
    b = bar(itemp,mean(FIratio_cfs_mono_15(itemp)));
    b.FaceAlpha = 1;
    b.FaceColor = colorlist(itemp,:);
    b.EdgeColor = 'none';
    b.BarWidth = 0.5;
end
hold off
xticks(1)
xticklabels({})
ylim([0,0.9])
yticks([0 0.2 0.4 0.6 0.8])
ylabel("FI (with/without CFS)")
legend(p, {'MA','MB'},'Interpreter','none','Box','off')
ax = gca;
set(ax, 'Box', 'off', 'LineWidth', 1.5, 'FontSize', 12);
