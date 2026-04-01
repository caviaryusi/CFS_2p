% %%This Program correct the scanline shift and XY shift. 
% 2018Ver01, faster correlation algrathom.
% 2018Ver10, save fAesei as binary file, not mat file. It's very fast.
% 2018Ver11, examin Z consistance between each trial.
% 2018Ver13, rename NF(number of frame) to NI(number of images), to avoid confusing with number of forms.
%%
fAesei = reshape(fAesei,512,512,[]);

tNum = size(fAesei,3);
refNum=3000;
refFrameRange = ceil((tNum-refNum)/2+(1:refNum)); 
forceSavefAesei = 1;
saveTiff = 0;
interlacingCorrection = 1;
xAdjust = 0;  %exclude dark area,must <100, set to zero in default
yAdjust = 0;  %exclude dark area,must <100, set to zero in default
% checkRefImageManully = 0;


%%
% disp('get refImage from original data ...');
refA = fAesei(:,:,refFrameRange);
%% seperate refA into 5 groups, check correlation of each group
% take one group which have the most correlation with others as final ref
tfnum = size(refA,3);
gfnum = floor(tfnum/refNum); 
% grefA = zeros(512,512,5,'uint16');
% for gi = 1:4000
%     grefA(:,:,gi) = mean(refA(:,:,(1:gfnum)+(gi-1)*gfnum),3);
% %     figure(gi);
% %     imshow(grefA(:,:,gi),[1 2000]);
% end
% grefA = reshape(grefA,512*512,4000);
grefA = refA(:,:,1:refNum);
grefA = reshape(grefA,512*512,refNum);
tic;
ce = corr(double(grefA));
toc;

%%
cec = ce;
cec(ce==1)=min(ce(:));
% imagesc(cec);axis equal
mce = mean(cec);
% plot(mce);
[~,bestImageIdx] = max(mce);
ceBest = ce(bestImageIdx,:);
th = mean(cec(:)) + std(cec(:))*1.5;
bestCorrIdx = find(ceBest>th);
disp(length(bestCorrIdx));
ma = mean(refA(:,:,bestCorrIdx),3);
% figure,imshow(ma,[]);
imY1 = ma;
figure;imshow(imY1/1e3)
saveas(gcf,'imY1beforeCorr.fig')
%% figure,imagesc(ce);
% [~,Imax] = max(mean(ce));
% Igood = find(ce(6,:)>0.95); %using groups of ce>0.9 to produce imY1
% grefA = reshape(grefA,512,512,[]);
% imY1 = mean(grefA(:,:,Igood),3);

%% interlacing correction
if interlacingCorrection
    imY2 = imY1;
    odd = imY1(1:2:end,:)';
%     figure(1),imshow(odd',[1 2000]);
    even = imY1(2:2:end,:)';
%     figure(2),imshow(even',[1 2000]);
    evenSub = even(5:end-10);%Æ½ÒÆ·¶Î§ 5 +/- 4 pixel
    dataLenght = length(evenSub);
    ccA = zeros(1,9);
    for i = 1:9
        oddSub = odd((1:dataLenght)+i-1);
        cc = corrcoef(oddSub,evenSub);
        ccA(i) = cc(1,2);
    end
    [~,I] = max(ccA);
    % I = 4;
    ds = (5-I);% odd row move ds pixels to the right.
    disp(['interlacing shift:   ' int2str(ds) ' pixels.']);
    if ds==0
        interlacingCorrection = 0;
        disp('NO need for interlacing correction.');
    else
        if ds>0
            imY2(1:2:end,ds+1:end) = imY1(1:2:end,1:end-ds);
            fAesei(1:2:end,ds+1:end,:)=fAesei(1:2:end,1:end-ds,:);
        elseif ds<0
            imY2(1:2:end,1:end+ds) = imY1(1:2:end,1-ds:end);
            fAesei(1:2:end,1:end+ds,:)=fAesei(1:2:end,1-ds:end,:);
        end
        figure,imshow(imY2,[1 2000]);
        title('mean image with interlacing correction');
        pause(0.1);
        imY1 = imY2;
    end
end
% 
figure,imshow(imY1,[1 1000]);
% title(['Average image from raw frame of ' int2str(length(bestCorrIdx))],'color','r','FontSize',18);
savefig('imY1');
% odd = imY2(1:2:end,:)';
%     figure(11),imshow(odd',[1 2000]);
%     even = imY2(2:2:end,:)';
%     figure(12),imshow(even',[1 2000]);
%     evenSub = even(5:end-10);%Æ½ÒÆ·¶Î§ 5 +/- 4 pixel
%% check exsistance of foreign imY1
% close all
matList = dir('*.mat');
for i = 1:length(matList)
    matfn = matList(i).name;
    k = strfind(matfn,'imY1');
    if isempty(k)
        imY1_foreign_loaded = 0;
    else
        disp(['load: ' matfn]);
        clear imY1;
        load(matfn);
        figure,imshow(imY1,[1 2000]);
        title(['imY1 loaded from imY1\_' matfn((end-6):(end-4)) ', acting reference image']);
        imY1_foreign_loaded = 1;
        break;
    end
end
if ~imY1_foreign_loaded
    save(['imY1_' name],'imY1');
end
%%
% fAesei = reshape(A,dataSetDim(1),dataSetDim(2),[]);
fAnum = size(fAesei,3);
% fAc = fAesei;
%% fastest correlation version
% tic;
refFrame = imY1;
corrResults = zeros(fAnum,3);
blockSz = 1000;
blockNum = ceil(fAnum/blockSz);
roiSz = 200;
margeSz = 60;
%--------------------prepare refSubA2
travelRange = (1:(margeSz*2+1))+((512-roiSz)/2-margeSz);
refSubA = zeros(roiSz,roiSz,margeSz*2+1,margeSz*2+1);
for i = 1:(margeSz*2+1)
    for j = 1:(margeSz*2+1)
        refSubA(:,:,i,j) = refFrame(travelRange(i)+(1:roiSz),travelRange(j)+(1:roiSz));
    end
end
refSubA2 = reshape(refSubA,roiSz^2,[]);
%--------------------cross correlation and correction
for bi=1:blockNum
    tic;
    if bi<blockNum
        T = fAesei(:,:,(1:blockSz)+(bi-1)*blockSz);
    else
        T = fAesei(:,:,((bi-1)*blockSz+1):fAnum);
    end
    corrR = ones(size(T,3),3);
    roiA = T((1:roiSz)+(512-roiSz)/2,(1:roiSz)+(512-roiSz)/2,:);
    roiA2 = double(reshape(roiA,roiSz^2,[]));
    ceA = corr(refSubA2,roiA2);
    ceA = reshape(ceA,margeSz*2+1,margeSz*2+1,[]);
    % motion correction
    for fi = 1:size(T,3)
        %     figure(2),imshow(T(:,:,fi),[]);
        c = ceA(:,:,fi);
        [~, imax] = max(c(:));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        xbias = xpeak-margeSz;
        ybias = ypeak-margeSz;
        corrR(fi,1:2) = [xbias ybias];
        if abs(xbias)<margeSz && abs(ybias)<margeSz
            cf = padarray(T(:,:,fi),[margeSz margeSz],'both');%pad array with zeros
            T(:,:,fi) = cf((1:512)+margeSz-ybias,(1:512)+margeSz-xbias);
        else
            disp('exception: exceed margeSize!');
            corrR(fi,3) = 0;
        end
        %     figure(2),imshow(C(:,:,fi),[]);
    end
%     Tshift = bitshift(T,-3);
    if bi<blockNum
        fAesei(:,:,(1:blockSz)+(bi-1)*blockSz) = T;
        corrResults((1:blockSz)+(bi-1)*blockSz,:) = corrR;
        disp((bi-1)*blockSz)
    else
        fAesei(:,:,((bi-1)*blockSz+1):fAnum) = T;
        corrResults(((bi-1)*blockSz+1):fAnum,:) = corrR;
        disp('done');
    end
    toc;

end
% figure(2),imshow(mean(T,3),[],'colormap',parula(256));
% title('motion corrected average');
%% show corrResults
figure;hold on
plot(corrResults(:,1));
plot(corrResults(:,2));
R = corrResults(:,3);
plot(find(R==0),zeros(1,length(find(R==0))),'*k');

elapsedTime = toc;
disp(['performance: ' num2str(elapsedTime/NumFrame*1000) ' seconds per 1000 frames']);
figure,plot(corrResults);
% ylim([-0.2 1.2]);
title('corrResults');
savefig('corrResults');
% figure,imagesc(A(:,:,1)),axis image;axis off;
% figure,imagesc(c),axis image;axis off;
save corrResults corrResults
%%
meanImage0 = mean(fAesei,3);
imY1 = meanImage0;
save(['imY1_' name],'imY1');% update imY1

meanImage = mat2gray(meanImage0);
save meanImage meanImage;
meanImage = mat2gray(meanImage,[0 0.5]);
figure,imshow(meanImage*3);
imwrite(meanImage*3,'averagedImage.tif');
%% examin Z consistance between each trial.
fAesei = reshape(fAesei,512,512,NI,NS,NT);
mImage = squeeze(mean(sum(fAesei,3),4));
for nti = 1:NT
    figure,
    imshow(mImage(:,:,nti),[0 32000]);
    title(['average image of trial ' int2str(nti)]);
end
%% saving fAesei.mat
if forceSavefAesei
    tic;
    fn = sprintf('fAesei_512_512_%d_%d_%d_uint16_%s.datbin',NI,NS,NT,name);
    disp(['saving' fn '......']);
    fullfn = fullfile(Mdir,fn);
    f = fopen(fullfn, 'w');
    fwrite(f, fAesei, 'uint16');
    fclose(f);
    disp('fAesei saved');
    toc;
else
    prompt = 'Do you want to save fAesei.mat? Y/N [N]: ';
    str = input(prompt,'s');
    if isempty(str)
        str = 'N';
    end
    if strcmpi(str,'Y')
        fn = sprintf('fAesei_512_512_%d_%d_%d_uint16.datbin',NI,NS,NT);
        disp(['saving' fn '......']);
        fullfn = fullfile(Mdir,fn);
        f = fopen(fullfn, 'w');
        fwrite(f, fAesei, 'uint16');
        fclose(f);
        disp('fAesei saved');
    end
end
