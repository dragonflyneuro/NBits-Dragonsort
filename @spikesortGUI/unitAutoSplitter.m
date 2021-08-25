function [clust, yn] = unitAutoSplitter(app, n, idx)
% crop waves for better PCA
u = app.unitArray(n);

if isempty(idx)
    idx = 1:size(u.waves,1);
end
% croppedWaves = u.waves(idx,ceil(size(u.waves,2)/2) + (round(-0.2/app.msConvert):round(0.15/app.msConvert)),:);
% croppedWaves = reshape(croppedWaves, length(idx), []);
croppedWaves = u.waves(idx,:);

% perform PCA and cluster waves
PC = pca(croppedWaves);
PCwaves = croppedWaves*PC(:,1:3);
clust = kmeans(PCwaves',app.AutosplitField.Value);
numClust = length(unique(clust));

% plot waveforms, separated into subplots for different
% clusters
f = figure;
set(f, 'Position',  [300, 200, 1200, 700]);
ax = gobjects(numClust,1);
yTemp = zeros(numClust,2);

for ii = 1:numClust
    if sum(clust==ii) ~= 0
        ax(ii) = subplot(ceil(numClust/4),4,ii,'Parent',f);
        line(ax(ii), -app.m.spikeWidth:app.m.spikeWidth, u.waves(:,:,u.mainCh)', 'Color', [0.8, 0.8, 0.8]);
        line(ax(ii), -app.m.spikeWidth:app.m.spikeWidth, u.waves(clust==ii,:,app.m.mainCh)');
        %                 xlabel(ax(ii), "Samples"); ylabel(ax(ii), "Amplitude (uV)");
        yTemp(ii,:) = ylim(ax(ii));

        if ii == 1
            title(ax(ii),"Unit " + string(n) + " " + ...
                 sum(clust==ii) + " spikes", 'Color', getColour(n));
        else
            uN = length(app.unitArray)+ii;
            title(ax(ii),"New unit " + string(uN) + " " + ...
                sum(clust==ii) + " spikes", 'Color', getColour(uN));
        end
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
    axis(ax(ii),'square');
end
sgtitle("Template splitting: ENTER to accept, close/ESC to reject")

% ask user if they want to accept the new assignments
% yn = 1 if enter was pressed
[yn, ~] = getFigData(f);
end