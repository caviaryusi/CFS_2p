%% given a subset of population, under certain condition, see the capacity of orientation decoding of neurons

%% clear history variables
clearvars;
clear global;
clc; close all;

%% raw data pathes
data_root = 'H:/2023/Research/CFS/';
MA_1 = [data_root 'data/Data_repository/MA_1/'];
MA_2 = [data_root 'data/Data_repository/MA_2/'];
MB_1 = [data_root 'data/Data_repository/MB_1/'];
MB_2 = [data_root 'data/Data_repository/MB_2/'];
MA_3 = [data_root 'data/Data_repository/MA_3/'];
MA_4 = [data_root 'data/Data_repository/MA_4/'];

dataPathList = {MA_1, MA_2, MB_1, MB_2, MA_3, MA_4};
dataNameList = {'MA_1', 'MA_2', 'MB_1', 'MB_2', 'MA_3', 'MA_4'};

for iPath = 1
    % load necessary datum
    load([dataPathList{iPath} 'ODI.mat'], "ODI");
    load([dataPathList{iPath} 'targetcell_contra_1.mat'], "targetcell_contra_1");
    load([dataPathList{iPath} 'targetcell_ipis_1.mat'], "targetcell_ipis_1");
    load([dataPathList{iPath} 'targetcell_base_1.mat'], "targetcell_base_1");
    load([dataPathList{iPath} 'G4_RspAvgOFFListTotal_base.mat']);

    % for each orientation, extract population neural response pattern and
    % label tagging
    num_sf = 2; num_oris = 12; num_repeat = size(G4_RspAvgOFFListTotal_base, 3); num_neuron = size(G4_RspAvgOFFListTotal_base, 1);
    [bino_list, mono_contra_list, mono_ipis_list, cfs_contra_list, cfs_ipis_list] = deal(zeros(size(G4_RspAvgOFFListTotal_base, 1),num_oris*num_sf*num_repeat)); % neuron * sample
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

    % extract on ori pair
    ori_pair = [1 2; 2 3; 3 4; 4 5; 5 6; 6 7; 7 8; 8 9; 9 10; 10 11; 11 12; 12 1];
    num_folds = 5;

    % response_list
    Resp_list = {mono_contra_list, mono_ipis_list, cfs_contra_list,cfs_ipis_list};
    Acc_list = {}; 

    %% do model training
    for itemp = 1:length(Resp_list) % loop over each condition

        accuracies = zeros(size(ori_pair, 1), num_folds); % ori_pair, number of folds
        for ipair = 1:12 % loop over each orientation pair
            cur_idx = find(labels == ori_pair(ipair,1)|labels == ori_pair(ipair,2));
            labels_cur = labels(cur_idx);
            responses = Resp_list{itemp}(:,cur_idx)';

            X = responses;
            y = labels_cur;
            k = num_folds;
            cv = cvpartition(length(y), 'KFold', k);
 
            for i = 1:k
                trainX = X(training(cv, i), :);
                trainY = y(training(cv, i));
                testX = X(test(cv, i), :);
                testY = y(test(cv, i));
                % Train SVM Model
                SVMModel = fitcsvm(trainX, trainY, 'KernelFunction', 'linear', 'Standardize', true);
    
                % Predict on test set
                Y_pred = predict(SVMModel, testX);
    
                % Compute accuracy
                accuracies(ipair, i) = sum(Y_pred == testY) / length(testY);
            end

            % print result
            mean_accuracy = mean(accuracies(ipair,:));
            fprintf('Cur data: %d, ori pair: %d, mean acc: %.2f%%\n', itemp, ipair, mean_accuracy*100);
        end

        Acc_list{itemp} = accuracies;
    end

end