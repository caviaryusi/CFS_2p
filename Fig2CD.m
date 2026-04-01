%% given a subset of population, draw it's pop ori tuning under different conditions (according to stimu/noise eye preference)
%% with population orientation tuning fitting and params

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

%% figure parameters
fig = figure;
tiledlayout(2,4);
set(fig, 'Position', [100, 300, 1200, 550])

pooled_list = {[1 2], [3 4], [5 6]};

for iPool = [1 2]
    num_oris = 12;
    [bino_list, mono_contra_list, mono_ipis_list, cfs_contra_list, cfs_ipis_list] = deal([]);
    [noise_contra_list, noise_ipis_list, ODI_list, Y1_base, Y1_contra, Y1_ipis] = deal([]);

    icount = 0;
    for iPath = pooled_list{iPool}
        % load necessary datum
        load([dataPathList{iPath} 'ODI.mat'], "ODI");
        load([dataPathList{iPath} 'Y1_AnovaListTotal_base.mat'], "Y1_AnovaListTotal_base");
        load([dataPathList{iPath} 'Y1_AnovaListTotal_contra.mat'], "Y1_AnovaListTotal_contra");
        load([dataPathList{iPath} 'Y1_AnovaListTotal_ipis.mat'], "Y1_AnovaListTotal_ipis");
        load([dataPathList{iPath} 'G4_PeakOriListTotal_base.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_base.mat']);
        load([dataPathList{iPath} 'G4_PeakOriListTotal_ipis.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_ipis.mat']);
        load([dataPathList{iPath} 'G4_PeakOriListTotal_contra.mat']); load([dataPathList{iPath} 'G4_PeakSfListTotal_contra.mat']);
        load([dataPathList{iPath} 'G4_RspMeanTrialStdSeListTotal_base.mat']);

        % for each neuron, each condition, select its ori tuning under most
        % preferred sf, and align most preferred ori to the 1st element
        % [binocular, monocular_contralateral eye, monoocular ipislateral eye,
        % csf_grating on contralateral eye, cfs_grating on ipislateral eye]
        for ci = 1:size(G4_RspMeanTrialStdSeListTotal_base,1)
            icount = icount + 1;
            % extract sf and ori preference under each eye condition
            sflist = [G4_PeakSfListTotal_contra(ci) G4_PeakSfListTotal_ipis(ci) G4_PeakSfListTotal_base(ci)];
            orilist = [G4_PeakOriListTotal_contra(ci) G4_PeakOriListTotal_ipis(ci) G4_PeakOriListTotal_base(ci)];

            bino_idx = 96+(sflist(3)-1)*12+1:96+(sflist(3)-1)*12+num_oris; % peak sf
            mono_contra_idx = 48+(sflist(1)-1)*12+1:48+(sflist(1)-1)*12+num_oris;
            mono_ipis_idx = 72+(sflist(2)-1)*12+1:72+(sflist(2)-1)*12+num_oris;
            cfs_contra_idx = 0+(sflist(1)-1)*12+1:0+(sflist(1)-1)*12+num_oris;
            cfs_ipis_idx = 24+(sflist(2)-1)*12+1:24+(sflist(2)-1)*12+num_oris;
            noise_contra_idx = 121;
            noise_ipis_idx = 122;

            bino_list(icount,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,bino_idx,1),12-orilist(3)+1);
            mono_contra_list(icount,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,mono_contra_idx,1),12-orilist(1)+1);
            mono_ipis_list(icount,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,mono_ipis_idx,1),12-orilist(2)+1);
            cfs_contra_list(icount,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,cfs_contra_idx,1),12-orilist(1)+1);
            cfs_ipis_list(icount,:) = circshift(G4_RspMeanTrialStdSeListTotal_base(ci,cfs_ipis_idx,1),12-orilist(2)+1);
            noise_contra_list(icount,:) = repmat(G4_RspMeanTrialStdSeListTotal_base(ci,noise_contra_idx,1), [1,12]);
            noise_ipis_list(icount,:) = repmat(G4_RspMeanTrialStdSeListTotal_base(ci,noise_ipis_idx,1), [1,12]);
            ODI_list(icount,:) = ODI(ci);
            Y1_base(icount) = Y1_AnovaListTotal_base(ci);
            Y1_contra(icount) = Y1_AnovaListTotal_contra(ci);
            Y1_ipis(icount) = Y1_AnovaListTotal_ipis(ci);
        end
    end

    linestoplot = {bino_list, mono_contra_list, mono_ipis_list,...
        cfs_contra_list, cfs_ipis_list};
    legends = {'bino','mono_contra','mono_ipis','cfs_contra','cfs_ipis'};
    neuron_idx = {find( ODI_list<-0.2 & (Y1_base'<.01 | Y1_contra'<.01 | Y1_ipis'<.01)), ...
        find(abs(ODI_list)<=0.2 & (Y1_base'<.01 | Y1_contra'<.01 | Y1_ipis'<.01)), ...
        find(ODI_list>0.2 & (Y1_base'<.01 | Y1_contra'<.01 | Y1_ipis'<.01)), ...
        find((Y1_base'<.01 | Y1_contra'<.01 | Y1_ipis'<.01))};
    num_of_lines = length(neuron_idx);
    colorlist = turbo(num_of_lines+2);
    colorlist = colorlist(2:size(colorlist,1), :);
    fitparams = zeros(num_of_lines,7);

    % plot ori tuning functions
    params_all = [];
    for j = [4 3 2 1]
        if j == 1 % prefer stimuli eye
            linestoplot = {[bino_list(neuron_idx{1},:); bino_list(neuron_idx{3},:)],... % binocular
                [mono_contra_list(neuron_idx{1},:); mono_ipis_list(neuron_idx{3},:)],... % monocular, grating at preferred eye
                [cfs_contra_list(neuron_idx{1},:); cfs_ipis_list(neuron_idx{3},:)]}; % cfs, grating at preferred eye
            dotstoplot = [noise_contra_list(neuron_idx{1},:); noise_ipis_list(neuron_idx{3},:)];
            neuro_num = length(neuron_idx{1}) + length(neuron_idx{3});
            ODImean = mean(abs(ODI_list([neuron_idx{1}; neuron_idx{3}])));
        elseif j == 2 % middle, no much preference
            linestoplot = {[bino_list(neuron_idx{2},:)],... % binocular
                [mono_contra_list(neuron_idx{2},:); mono_ipis_list(neuron_idx{2},:)],... % monocular, grating at either eye
                [cfs_contra_list(neuron_idx{2},:); cfs_ipis_list(neuron_idx{2},:)]}; % cfs, grating at either eye
            dotstoplot = [noise_contra_list(neuron_idx{2},:); noise_ipis_list(neuron_idx{2},:)];
            neuro_num = length(neuron_idx{2});
            ODImean = mean(abs(ODI_list(neuron_idx{2})));
        elseif j == 3 % prefer noise eye
            linestoplot = {[bino_list(neuron_idx{3},:); bino_list(neuron_idx{1},:)],... % binocular
                [mono_contra_list(neuron_idx{3},:); mono_ipis_list(neuron_idx{1},:)],... % monocular, grating at non-preferred eye
                [cfs_contra_list(neuron_idx{3},:); cfs_ipis_list(neuron_idx{1},:)]}; % cfs, grating at non-preferred eye
            dotstoplot = [noise_contra_list(neuron_idx{3},:); noise_ipis_list(neuron_idx{1},:)];
            neuro_num = length(neuron_idx{1}) + length(neuron_idx{3});
            ODImean = mean(abs(ODI_list([neuron_idx{1}; neuron_idx{3}])));
        elseif  j == 4 % all neurons
            linestoplot = {[bino_list(neuron_idx{4},:)],... % binocular
                [mono_contra_list(neuron_idx{4},:); mono_ipis_list(neuron_idx{4},:)],... % monocular, grating at non-preferred eye
                [cfs_contra_list(neuron_idx{4},:); cfs_ipis_list(neuron_idx{4},:)]}; % cfs, grating at non-preferred eye
            dotstoplot = [noise_contra_list(neuron_idx{4},:); noise_ipis_list(neuron_idx{4},:)];
            neuro_num = length(ODI_list(neuron_idx{4}));
            ODImean = mean(abs(ODI_list(neuron_idx{4})));
        end
        legends = {'bino','mono','cfs'};
        neuron_legends = {'Preferring grating eye', 'Binocular', 'Preferring noise eye', 'All'};
        nexttile;
        %     figure
        hold on
        p = [];
        colorlist = [115 180 77; 216 33 28; 41 155 207]/255;  % colorlist = [255 0 0; 0 255 0; 0 0 255]/255;
        marker = {"d", "o", "^"};
        text(-95, 0.57, sprintf('Amp Width R^2 Slope'),'color', 'k')
        for i = 2:length(linestoplot)
            yValue = circshift(linestoplot{i}, 6, 2);

            % the Gaussian fitting
            [expect, params, R2, adjR2, slope] = GaussianOriFitting_centered(-90:15:75, mean(yValue,1), calcSE(yValue,1));
            if j ~= 4
                plot(-105:1:90, (params(1)*2.^(-(([-105:1:90]-params(2))/params(3)).^2)+params(4)), 'Color', colorlist(i,:), 'LineWidth', 1);
                p(i) = errorbar(-90:15:75,mean(yValue,1),calcSE(yValue,1), marker{i}, 'MarkerSize', 7, "MarkerEdgeColor",colorlist(i,:),'LineWidth',1,'Color',colorlist(i,:));
            else
                if i == 2 % mono
                    plot(-105:1:90, (params(1)*2.^(-(([-105:1:90]-params(2))/params(3)).^2)+params(4)), 'Color', colorlist(i,:), 'LineWidth', 1.5, 'LineStyle','-');
                    p(i) = errorbar(-90:15:75,mean(yValue,1),calcSE(yValue,1), marker{i}, 'MarkerSize', 7, "MarkerEdgeColor",colorlist(i,:),'LineWidth',1.5,'Color',colorlist(i,:));

                else % cfs
                    plot(-105:1:90, (params(1)*2.^(-(([-105:1:90]-params(2))/params(3)).^2)+params(4)), 'Color', colorlist(i,:), 'LineWidth',1.5, 'LineStyle','-');
%                     set(gcs, 'DashSpacing',2);
                    p(i) = errorbar(-90:15:75,mean(yValue,1),calcSE(yValue,1), marker{i}, 'MarkerSize', 7, "MarkerEdgeColor",colorlist(i,:),'LineWidth',1.5,'Color',colorlist(i,:));
                end
            end
            text(-95, 0.57-(i)*0.04, sprintf('%.2f %.2f %.2f %5.4f\n', params(1), params(3), R2, slope),'color', colorlist(i,:))
            params_all((j-1)*3+i,:) = [params, R2, adjR2, slope];

            % the vonMises fitting
            %             [expect, params, R2, adjR2] = vonMisesOriFitting(-90:15:75, mean(yValue,1), calcSE(yValue,1));
            %             plot(-105:1:90, vmpdf(deg2rad(-105:1:90)', params(1), params(2), params(3), params(4)), 'Color', colorlist(i,:), 'LineWidth', 1);
            %             text(-95, 0.6-i*0.03, sprintf('amp = %.2f, concen = %.2f, adjR^2 = %.2f\n', params(3), params(2), adjR2),'color', colorlist(i,:))
        end
        text(40, 0.65, [' N = ', num2str(neuro_num)], 'color', 'k')
        xlim([-105 90])
        xticks([-90, -45, 0, 45, 90])
        xticklabels({"-90","-45","0","45","90"})
        %         if iPath == 8
        %             xlabel("Relative orientation preference")
        %         end
        ylim([0.05 0.7])
        yticks([0.1 0.3 0.5 0.7])
        if iPath == 3
            title(sprintf('%s', neuron_legends{j}))
        end
        hold off
        ax = gca;
        set(ax, 'Box', 'off', 'LineWidth', 1, 'FontSize', 12);
    end
    T = array2table(params_all);
    T.Properties.VariableNames = {'amp', 'peak', 'sigma',  'baseline', 'r2', 'adr2', 'slope'};

end
