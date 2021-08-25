function [clust, yn] = unitAutoMerger(u, n, idx, yl)
% crop waves for better PCA

spikeWidth = size(u(1).waves,2);

% croppedWaves = u.waves(idx,ceil(size(u.waves,2)/2) + (round(-0.2/app.msConvert):round(0.15/app.msConvert)),:);
% croppedWaves = reshape(croppedWaves, length(idx), []);
croppedWaves = u(n).waves(idx,:);
unitsToMergeTo = setdiff(1:length(u),n);
[waves, PC] = getPCs(u, unitsToMergeTo);
for ii=1:length(u)
    spikePC{ii} = waves{ii}*PC(:,1:3);
end

% perform PCA and cluster waves
wavesToMergePC = croppedWaves*PC(:,1:3);
for ii = 1:length(spikePC)
    meanSpikePC(ii,:) = mean(spikePC{ii});
end

for ii = 1:length(wavesToMergePC)
    dists = squareform(pdist([wavesToMergePC(ii,:);meanSpikePC]));
    [~, minIdx] = min(dists(1,2:end));
    clust(ii) = unitsToMergeTo(minIdx);
end
numClust = length(unique(clust));

% plot waveforms, separated into subplots for different
% clusters
f = figure('Name','Automerge');
set(f, 'Position',  [300, 200, 1200, 700]);
ax = gobjects(numClust,1);
yTemp = zeros(numClust,2);

ax(1) = subplot(ceil((numClust+1)/4),4,1,'Parent',f);
line(ax(1), -spikeWidth:spikeWidth, u(n).waves(:,:,u(n).mainCh)', 'Color', [0.8, 0.8, 0.8]);
yTemp(1,:) = ylim(ax(1));

title(ax(1),"Unit " + string(n) + " losing " + ...
    string(length(u(n).spikeTimes)-length(idx)) ...
    + " spikes", 'Color', getColour(n));

cc = 1;
for ii = unitsToMergeTo
    if sum(clust==ii) ~= 0
        cc = cc+1;
        ax(cc) = subplot(ceil((numClust+1)/4),4,cc,'Parent',f);
        line(ax(cc), -spikeWidth:spikeWidth, u(ii).waves(:,:,u(ii).mainCh)', 'Color', [0.8, 0.8, 0.8]);
        line(ax(cc), -spikeWidth:spikeWidth, u(n).waves(idx(clust==ii),:,u(n).mainCh)');
        %                 xlabel(ax(ii), "Samples"); ylabel(ax(ii), "Amplitude (uV)");
        yTemp(ii,:) = ylim(ax(cc));
        
        title(ax(cc),"Unit " + string(ii) + " " + ...
            string(length(u(ii).spikeTimes)+sum(clust==ii)) ...
            + " spikes", 'Color', getColour(ii));
    end
end

% match ylim of each subplot
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
yTemp(~isinf(yl)) = yl(~isinf(yl));

for ii = 1:cc
    ylim(ax(ii), yTemp);
    axis(ax(ii),'square');
end
sgtitle("Template splitting: ENTER to accept, close/ESC to reject")

% ask user if they want to accept the new assignments
% yn = 1 if enter was pressed
[yn, ~] = getFigData(f);
end