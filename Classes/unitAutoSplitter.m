function [clust, yn] = unitAutoSplitter(u, n, idx, numSplit, yl)
% crop waves for better PCA

spikeWidth = (size(u(n).waves,2)-1)/2;
% no spikes
if spikeWidth < 0 || length(idx) < 2
    clust = [];
    yn = 0;
    return;
end

% croppedWaves = u.waves(idx,ceil(size(u.waves,2)/2) + (round(-0.2/app.msConvert):round(0.15/app.msConvert)),:);
% croppedWaves = reshape(croppedWaves, length(idx), []);
croppedWaves = u(n).waves(idx,:);

% perform PCA and cluster waves
PC = pca(croppedWaves);
PCwaves = croppedWaves*PC(:,1:3);
clust = kmeans(PCwaves',numSplit);
numClust = length(unique(clust));

% plot waveforms, separated into subplots for different
% clusters
f = figure('Name','Autosplit');
set(f, 'Position',  [300, 200, 1200, 700]);
ax = gobjects(numClust,1);
yTemp = zeros(numClust,2);

for ii = 1:numClust
    if sum(clust==ii) ~= 0
        ax(ii) = subplot(ceil(numClust/4),4,ii,'Parent',f);
        line(ax(ii), -spikeWidth:spikeWidth, u(n).waves(:,:,u(n).mainCh)', 'Color', [0.8, 0.8, 0.8]);
        line(ax(ii), -spikeWidth:spikeWidth, u(n).waves(clust==ii,:,u(n).mainCh)');
        %                 xlabel(ax(ii), "Samples"); ylabel(ax(ii), "Amplitude (uV)");
        yTemp(ii,:) = ylim(ax(ii));

        if ii == 1
            title(ax(ii),"Unit " + string(n) + " " + ...
                 sum(clust==ii) + " spikes", 'Color', getColour(n));
        else
            uN = length(u)+ii;
            title(ax(ii),"New unit " + string(uN) + " " + ...
                sum(clust==ii) + " spikes", 'Color', getColour(uN));
        end
    end
end

% match ylim of each subplot
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
yTemp(~isinf(yl)) = yl(~isinf(yl));

for ii = 1:numClust
    ylim(ax(ii), yTemp);
    axis(ax(ii),'square');
end
sgtitle("Template splitting: ENTER to accept, close/ESC to reject")

% ask user if they want to accept the new assignments
% yn = 1 if enter was pressed
[yn, ~] = getFigData(f);
end