function [clust, yn] = unitAutoMerger(app, n, idx)
% crop waves for better PCA
u = app.unitArray(n);

if isempty(idx)
    idx = 1:size(u.waves,1);
end
% croppedWaves = u.waves(idx,ceil(size(u.waves,2)/2) + (round(-0.2/app.msConvert):round(0.15/app.msConvert)),:);
% croppedWaves = reshape(croppedWaves, length(idx), []);
croppedWaves = u.waves(idx,:);
unitsToMergeTo = setdiff(1:length(app.unitArray),n);
[~, clusPC, PC] = getPCs(app.unitArray, unitsToMergeTo);

% perform PCA and cluster waves
PCwaves = croppedWaves*PC(:,1:3);
for ii = 1:length(clusPC)
    meanClusPC(ii,:) = mean(clusPC{ii});
end

for ii = 1:length(PCwaves)
    dists = squareform(pdist([PCwaves(ii,:);meanClusPC]));
    [~, minIdx] = min(dists(1,2:end));
    clust(ii) = unitsToMergeTo(minIdx);
end
numClust = length(unique(clust));

% plot waveforms, separated into subplots for different
% clusters
f = figure;
set(f, 'Position',  [300, 200, 1200, 700]);
ax = gobjects(numClust,1);
yTemp = zeros(numClust,2);

ax(1) = subplot(ceil((numClust+1)/4),4,1,'Parent',f);
line(ax(1), -app.m.spikeWidth:app.m.spikeWidth, u.waves(:,:,u.mainCh)', 'Color', [0.8, 0.8, 0.8]);
yTemp(1,:) = ylim(ax(1));

title(ax(1),"Unit " + string(n) + " losing " + ...
    string(length(u.spikeTimes)-length(idx)) ...
    + " spikes", 'Color', app.cmap(rem(n-1,25)+1,:));

cc = 1;
for ii = unitsToMergeTo
    if sum(clust==ii) ~= 0
        cc = cc+1;
        ax(cc) = subplot(ceil((numClust+1)/4),4,cc,'Parent',f);
        line(ax(cc), -app.m.spikeWidth:app.m.spikeWidth, app.unitArray(ii).waves(:,:,u.mainCh)', 'Color', [0.8, 0.8, 0.8]);
        line(ax(cc), -app.m.spikeWidth:app.m.spikeWidth, u.waves(idx(clust==ii),:,app.m.mainCh)');
        %                 xlabel(ax(ii), "Samples"); ylabel(ax(ii), "Amplitude (uV)");
        yTemp(ii,:) = ylim(ax(cc));
        
        title(ax(cc),"Unit " + string(ii) + " " + ...
            string(length(app.unitArray(ii).spikeTimes)+sum(clust==ii)) ...
            + " spikes", 'Color', app.cmap(rem(ii-1,25)+1,:));
    end
end

% match ylim of each subplot
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];

if ~isinf(app.yLimLowField.Value)
    yTemp(1) = app.yLimLowField.Value;
end
if ~isinf(app.yLimHighField.Value)
    yTemp(2) = app.yLimHighField.Value;
end

for ii = 1:cc
    ylim(ax(ii), yTemp);
    axis(ax(ii),'square');
end
sgtitle("Template splitting: ENTER to accept, close/ESC to reject")

% ask user if they want to accept the new assignments
% yn = 1 if enter was pressed
[yn, ~] = getFigData(f);
end