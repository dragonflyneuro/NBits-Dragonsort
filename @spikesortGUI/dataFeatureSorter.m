function f = dataFeatureSorter(app, u)

selection = 1:length(u);

waves = cell(length(selection),1);

[~,~,unassignedInBatch] = u.getOrphanSpikes(app.t.rawSpikeSample,getBatchRange(app));
unassignedWaves = app.rawSpikeWaves(unassignedInBatch,:);
allClust = unassignedWaves;

for ii=1:length(u)
    waves{ii} = u(selection(ii)).waves(:,:);
    allClust = cat(1,allClust, u(selection(ii)).waves(:,:));
end

W = pca(allClust);

for ii=1:length(waves)
    spikeF{ii}=waves{ii}*W(:,1:6);
end

unassignedF = unassignedWaves*W(:,1:6);

%PCA view-interactive
f = uifigure('Name','Batch feature view');
set(f, 'Position',  [1100, 200, 800, 700]);
app.dataFeatureAx = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(app.dataFeatureAx,[-5 2 5]);

% ui elements
labels = "Feature"+string(1:6);
markerSizeSldr = uislider(f,'Position',[50 90 700 3], 'Value',20, 'Limits',[1 200],...
    'ValueChangingFcn',{@sliderMoving, app.dataFeatureAx});

for ii = 1:3
    axisChoice(ii) = uidropdown(f,'Items', labels, 'Value',labels(ii),...
        'Position',[100+200*(ii-1) 30 200 22],'UserData',ii);
end
axisChoice(3).Items = [axisChoice(3).Items," "];

for ii = 1:3
    set(axisChoice(ii),'ValueChangedFcn', {@axisChanged, app, axisChoice, markerSizeSldr,...
        [{unassignedF},spikeF], selection});
end

uibutton(f,'Position',[350 5 100 22], 'Text','ROI Select',...
    'ButtonPushedFcn',{@ROIClick, app, axisChoice, markerSizeSldr, [{unassignedF},spikeF],selection});

% update plot
updateDataFeatureAx(app, axisChoice, markerSizeSldr, [{unassignedF},spikeF], selection)
title(app.dataFeatureAx,'Batch feature view');

end

%% callbacks
function axisChanged(~, ~, app, choices, sldr, posData, sel)
updateDataFeatureAx(app, choices, sldr, posData, sel)

end

function ROIClick(~, ~, app, choices, sldr, posData, selection)
if app.interactingFlag(1) ~= 0
    return;
end

for ii = 1:3
    labels(ii) = string(choices(ii).Value);
end

selectedBool = ROI3D(posData,1,[0,0,0; getColour(1:length(selection))],...
    [".", getMarker(1:length(selection))],...
    sldr.Value*ones(size(posData)),labels);

addIdx = find(selectedBool{1});
if ~isempty(addIdx)
    [~, removeIdx, IC] = intersect(app.dataAx.UserData.selectedUnassigned,addIdx);
    addIdx(IC) = [];
    
    updateUnassignedSelection(app, addIdx, removeIdx);
    if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
        updateUnassignedSelectionF(app, addIdx, removeIdx);
    end
    updateUnassignedUD(app, addIdx, removeIdx);
end
end

