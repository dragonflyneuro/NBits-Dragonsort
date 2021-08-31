function [] = showPCAOverview(u, selection)

[waves, PC] = getPCs(u, selection);
for ii=1:length(waves)
    spikePC{ii}=waves{ii}*PC(:,1:6);
end

drawnow

%PCA view-interactive
f = uifigure('Name','PCA Overview');
set(f, 'Position',  [1100, 200, 800, 700]);
axPC = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(axPC,[-5 2 5]);

for ii=1:length(selection)
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    if ~isempty(u(selection(ii)).waves)
        scatter3(axPC,spikePC{ii}(:,1),spikePC{ii}(:,2),spikePC{ii}(:,3),20,...
            repmat(iiCmap,size(spikePC{ii},1),1),"Marker",ms); % 3D PCA plot
    end
end

labels = "PC"+string(1:6);
xlabel(axPC,labels(1)); ylabel(axPC,labels(2)); zlabel(axPC,labels(3));
title(axPC,'Units found - PCs view');
legend(axPC,"Unit " + selection);

markerSizeSldr = uislider(f,'Position',[50 80 700 3], 'Value',20, 'Limits',[1 200],...
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
    h.Children(ii).SizeData = e.Value;
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