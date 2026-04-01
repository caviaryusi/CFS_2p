clc;
clear;

root_path = pwd;
dataPathList = {[pwd '\Demo\']};
dataNameList = {'Demo'};

cur_path = dataPathList{1};
load([cur_path 'output_pred.mat']);
pred = output_pred(:,:,:);
load([cur_path 'output_true.mat']);
true = output_true(:,:,:);

% extract ori from the predictions
ori_pred = []; 
for i = 1:size(true,1)
    ori_pred(i) = calculate_vector_direction(squeeze(pred(i,:,:)));
end

% generate true ori label
true_ori = repmat(0:15:179, [1,12]);

% calculate error
err = min(abs(ori_pred - true_ori), 90);

ssim_pred = [];
for i = 1:size(true,1)
    ssim_pred(i) = ssim(squeeze(pred(i,:,:)),squeeze(true(i,:,:)));
end