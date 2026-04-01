%% given a subset of population, under certain condition, see the capacity of orientation decoding of neurons

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

dataPathList = {MA_1, MA_2, MB_1, MB_2};
dataNameList = {'MA_1', 'MA_2', 'MB_1', 'MB_2'};

fig = figure(1);
tiledlayout(4,2);
set(fig, 'Position', [100, 300, 1000, 900])
iFig = 0;
FIratio_cfs_mono_15 = [];
DPratio_cfs_mono_15 = [];
titlenames = {'MA_V1_1','MA_V1_2','MB_V1','MB_V1_2'};
for iPath = 1:4
    % load necessary datum
    load([dataPathList{iPath} 'ODI.mat'], "ODI");
    load([dataPathList{iPath} 'G4_PeakOriListTotal_base.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_base.mat']);
    load([dataPathList{iPath} 'G4_PeakOriListTotal_ipis.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_ipis.mat']);
    load([dataPathList{iPath} 'G4_PeakOriListTotal_contra.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_contra.mat']);
    load([dataPathList{iPath} 'G4_RspMeanTrialStdSeListTotal_base.mat']);
    load([dataPathList{iPath} 'G4_RspAvgOFFListTotal_base.mat']);

    % for each orientation, extract population neural response pattern and
    % label tagging
    num_sf = 2; num_oris = 12; num_repeat = size(G4_RspAvgOFFListTotal_base, 3); num_neuron = size(G4_RspAvgOFFListTotal_base, 1);
    [bino_list, mono_contra_list, mono_ipis_list, cfs_contra_list, cfs_ipis_list] = deal(zeros(size(G4_RspMeanTrialStdSeListTotal_base,1),num_oris*num_sf*num_repeat)); % neuron * sample
    % [binocular, monocular_contralateral eye, monoocular ipislateral eye,
    % csf_grating on contralateral eye, cfs_grating on ipislateral eye]
    % extract index
    bino_idx = 96+1:96+num_oris*num_sf;
    mono_contra_idx = 48+1:48+num_oris*num_sf;
    mono_ipis_idx = 72+1:72+num_oris*num_sf;
    cfs_contra_idx = 0+1:0+num_sf*num_oris;
    cfs_ipis_idx = 24+1:24+num_sf*num_oris;
    % extract resp
    bino_list = reshape(G4_RspAvgOFFListTotal_base(:,bino_idx,:), num_neuron, []);
    mono_contra_list = reshape(G4_RspAvgOFFListTotal_base(:,mono_contra_idx,:), num_neuron, []);
    mono_ipis_list = reshape(G4_RspAvgOFFListTotal_base(:,mono_ipis_idx,:), num_neuron, []);
    cfs_contra_list = reshape(G4_RspAvgOFFListTotal_base(:,cfs_contra_idx,:), num_neuron, []);
    cfs_ipis_list = reshape(G4_RspAvgOFFListTotal_base(:,cfs_ipis_idx,:), num_neuron, []);
    % tag label
    labels = repmat(((repmat(1:12, [1,2]))), [1, num_repeat]); labels = labels';

    % define a subpopulation of neurons
    neuron_idx = 1:length(ODI);
    %     lowbound = prctile(ODI, 33); highbound = prctile(ODI, 66);
    %     neuron_idx = {find((ODI<lowbound)), find((ODI>=lowbound)&(ODI<=highbound)), find((ODI>highbound))};
    %         neuron_idx = {find((ODI<lowbound)&(Y1_AnovaListTotal_all'<.05)), find((ODI>=lowbound)&(ODI<=highbound)&(Y1_AnovaListTotal_all'<.05)), find((ODI>highbound)&(Y1_AnovaListTotal_all'<.05))};
    %     neuron_legends = {'~33%', '33%~66%', '66%~'};
    %     neuron_idx = {find((ODI<-0.2)), find((abs(ODI)<=0.2)), find((ODI>0.2))};
    %     neuron_idx = {find((ODI<-0.2)&(Y1_AnovaListTotal_all'<.05)), find((abs(ODI)<=0.2)&(Y1_AnovaListTotal_all'<.05)), find((ODI>0.2)&(Y1_AnovaListTotal_all'<.05))};
    %     neuron_legends = {'ODI < -0.2', '-0.2 <= ODI <= 0.2', 'ODI > 0.2'};

    % response_list
    Resp_list = {bino_list, mono_contra_list, mono_ipis_list, cfs_contra_list,cfs_ipis_list};
    Acc_list = [];

    %% do model training
    for itemp = 1:5
        responses = Resp_list{itemp}';
        num_folds = 10;
        X = responses;
        y = labels;
        k = num_folds;
        cv = cvpartition(length(y), 'KFold', k);
        accuracy = zeros(k, 1); 
        for i = 1:k
            trainX = X(training(cv, i), :);
            trainY = y(training(cv, i));
            testX = X(test(cv, i), :);
            testY = y(test(cv, i));
            svmModel = fitcecoc(trainX, trainY);
%             ldaModel = fitcdiscr(trainX, trainY, 'DiscrimType', 'linear');
            yPred = predict(svmModel, testX);
            accuracy(i) = sum(yPred == testY) / length(testY);
        end
        mean_accuracy = mean(accuracy);
        fprintf('mean acc: %.2f%%\n', mean_accuracy*100);
        attin_acc = accuracy;
        Acc_list{itemp} = accuracy;
    end

    save([dataPathList{iPath} 'OvOSVM_acc.mat'], "Acc_list");
end

% saveas(gcf, [data_root 'results/pca_svr_ori'], 'epsc')
% saveas(gcf, [data_root 'results/pca_svr_ori'], 'fig')
% print([data_root 'results/pca_svr_ori'], '-depsc', '-painters'); % for vector graphics