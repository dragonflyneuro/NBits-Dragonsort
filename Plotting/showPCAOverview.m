function [] = showPCAOverview(u, selection)

[waves, PC] = getPCs(u, selection);
if size(PC,2) == 0
    return;
end

noWaves = cellfun(@(x) isempty(x), waves);
waves(noWaves) = [];
selection(noWaves) = [];

if isempty(waves)
    return;
end

for ii=1:length(waves)
    spikePC{ii}=waves{ii}*PC(:,1:6);
end
X = cat(1,spikePC{:});

nClusts = length(spikePC);
nSpikes = size(X, 1);
nSpikesPerClust = cellfun(@(x) size(x, 1), spikePC);
clustAssignments = [];
for ii = 1:length(spikePC)
    clustAssignments = cat(1,clustAssignments,ii*ones(nSpikesPerClust(ii),1));
end
clustMean = arrayfun(@(i) mean(X(clustAssignments == i, :)), 1:nClusts, 'UniformOutput', false);
clustMean = cell2mat(clustMean');
intras = arrayfun(@(i) norm(X(i, :) - clustMean(clustAssignments(i), :)), 1:nSpikes);
inters = arrayfun(@(i) min(arrayfun(@(j) norm(X(i, :) - clustMean(j, :)), setdiff(1:nClusts, clustAssignments(i)))), 1:nSpikes);
isos = inters ./ intras;
clusterIsos = arrayfun(@(i) mean(isos(clustAssignments == i)), 1:nClusts);
clusterIsos = round(clusterIsos,2);

drawnow

%PCA view-interactive
f = uifigure('Name','PCA Overview');
set(f, 'Position',  [1100, 200, 800, 700]);
axPC = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(axPC,[-5 2 5]);

scatterDK(spikePC,axPC,getColour(selection),getMarker(selection),10); % 3D PCA plot

labels = "Feature"+string(1:6);
xlabel(axPC,labels(1)); ylabel(axPC,labels(2)); zlabel(axPC,labels(3));
title(axPC,'PCA Overview');
legend(axPC,"Unit " + selection + " isoScore " + clusterIsos);

markerSizeSldr = uislider(f,'Position',[50 80 700 3], 'Value',10, 'Limits',[1 50],...
    'ValueChangingFcn',{@sliderMoving, axPC});
axisChoice(1) = uidropdown(f,'Items', labels, 'Value',labels(1),...
    'Position',[100 20 200 22]);
axisChoice(2) = uidropdown(f,'Items', labels, 'Value',labels(2),...
    'Position',[300 20 200 22]);
axisChoice(3) = uidropdown(f,'Items', [labels, " "], 'Value',labels(3),...
    'Position',[500 20 200 22]);
for ii = 1:3
    set(axisChoice(ii),'ValueChangedFcn', {@updateFig, spikePC, selection, axPC, axisChoice, markerSizeSldr});
end

end

%% callbacks
function sliderMoving(~, e, h)
for ii = 1:length(h.Children)
    h.Children(ii).MarkerSize = e.Value;
end
end

function updateFig(~, ~, posData, sel, h, axisChoice, sizeSldr)

for ii = 1:length(axisChoice)
    choice(ii) = find(strcmp(axisChoice(ii).Value,axisChoice(ii).Items),1,'first');
end
if choice(3) ~= length(axisChoice(3).Items)
    zlabel(h,axisChoice(1).Value);
else
    choice(3) = [];
end

updateView(h, posData, sel, choice, sizeSldr.Value);

sel = sel(cellfun(@(x) ~isempty(x),posData));
legend(h,"Unit " + sel,'AutoUpdate','off');

xlabel(h,axisChoice(1).Value);
ylabel(h,axisChoice(1).Value);
zlabel(h,axisChoice(1).Value);

end