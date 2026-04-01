%% visualize ODI on the 2p imaging template

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

% template normalization factor for each FOV
scalefactor = [1000 1000 1000 1000 1500 1500 2000 800];

% Create a new figure and set its size
fig = figure('Position', [100, 100, 2000, 1000]);
tiledlayout(2,4);
ifig = 0;

for iPath = 1:4
    % load necessary datum
    load([dataPathList{iPath} 'ODI.mat'], "ODI");
    load([dataPathList{iPath} 'targetcell_contra_1.mat'], "targetcell_contra_1");
    load([dataPathList{iPath} 'targetcell_ipis_1.mat'], "targetcell_ipis_1");
    load([dataPathList{iPath} 'targetcell_base_1.mat'], "targetcell_base_1");
    load([dataPathList{iPath} 'imY1']);
    load([dataPathList{iPath} 'CCtotal']);

    % histogram of ODI distribution
    ODI = ODI;
    ifig = ifig + 1;
    nexttile(ifig)
    histogram(ODI, 'Normalization','probability', 'BinWidth', 0.05)
    xlim([-1 1])
    ylim([0 0.21])
    yticks([0 0.05 0.10 0.15 0.20])
    ax = gca;
    set(ax, 'Box', 'off', 'LineWidth', 2, 'FontSize', 18);

    % mapping
    targetCell = {union(union(targetcell_base_1, targetcell_contra_1), targetcell_ipis_1)};
    [sumIm(1:size(imY1,1),1:size(imY1,1),1) sumIm(1:size(imY1,1),1:size(imY1,1),2) sumIm(1:size(imY1,1),1:size(imY1,1),3)] = deal(imY1/scalefactor(iPath)); % 2000 may vary, adjust to get better visualization
    % create the colorap
    colornum = 100; % Number of colors in the colormap
    % Create the first half of the colormap (blue to white)
    firstHalf = [linspace(0, 1, colornum/2)', linspace(0, 1, colornum/2)', linspace(1, 1, colornum/2)'];
    % Create the second half of the colormap (white to red)
    secondHalf = [linspace(1, 1, colornum/2)', linspace(1, 0, colornum/2)', linspace(1, 0, colornum/2)'];
    % Combine both halves
    colorOT = [firstHalf; secondHalf];
    maxValue = 1; minValue = -1;
    % plot
    for i = targetCell{1}
        P = CCtotal{i}; % point at each cell's pixels
        odi = ODI(i);
        normalizedValue = (odi - minValue) / (maxValue - minValue);
        cidx = min(colornum, max(1, ceil(normalizedValue * size(colorOT, 1))));
        for j = 1:length(P)
            id_x = mod(P(j),512);
            id_y = round((P(j) - id_x)/512)+1;
            % if mod == 0, then is the end of last column, should modify the results
            if(id_x==0)
                id_x = 512;
                id_y= id_y-1;
            end
            sumIm(id_x,id_y,:) = squeeze(colorOT(cidx, :));
        end
    end
    nexttile(ifig + 4)
    imshow(sumIm);
    text(0.03, 0.02, ['N = ' num2str(length(targetCell{1}))],'FontSize', 20, 'FontWeight', 'bold', 'Units', 'normalized', ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left','Color',[1 1 0])

end