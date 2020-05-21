function [clust, yn] = unitAutoSplitter(app, w, n)
% crop waves for better PCA
croppedWaves = w(:,ceil(size(w,2)/2) + (round(-0.2/app.msConvert):round(0.15/app.msConvert)),:);
croppedWaves = reshape(croppedWaves, size(w,1), []);

% perform PCA and cluster waves
PC = pca(croppedWaves);
PCwaves = croppedWaves*PC(:,1:3);
clust = kmeans_opt(PCwaves,app.AutosplitField.Value);
numClust = length(unique(clust));

% plot waveforms, separated into subplots for different
% clusters
f = figure;
set(f, 'Position',  [300, 200, 1200, 700]);
ax = gobjects(numClust,1);
yTemp = zeros(numClust,2);

for ii = 1:numClust
    ax(ii) = subplot(ceil(numClust/4),4,ii,'Parent',f);
    axis square;
    line(ax(ii), -app.m.spikeWidth:app.m.spikeWidth, w', 'Color', [0.8, 0.8, 0.8]);
    line(ax(ii), -app.m.spikeWidth:app.m.spikeWidth, w(clust==ii,:,app.m.mainCh)');
    %                 xlabel(ax(ii), "Samples"); ylabel(ax(ii), "Amplitude (uV)");
    yTemp(ii,:) = ylim(ax(ii));
    
    if ii == 1
        title(ax(ii),"Unit "+n, 'Color', app.cmap(rem(str2double(n)-1,25)+1,:));
    else
        title(ax(ii),"Unit "+str2double(app.getMaxUnit(ii-1)), 'Color', app.cmap(rem(str2double(app.getMaxUnit(ii-1))-1,25)+1,:))
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

for ii = 1:numClust
    ylim(ax(ii), yTemp);
    axis(ax,'square');
end
sgtitle("Template splitting: ENTER to accept, close to reject")

% ask user if they want to accept the new assignments
% yn = 1 if enter was pressed
[yn, ~] = getFigData(f);
end