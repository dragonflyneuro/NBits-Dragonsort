function f = dataFeatureSorter(app, u, varargin)

if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
    f = app.dataFeatureAx.Parent;
    clf(f);
else
    f = uifigure('Name','Batch feature view');
    set(f, 'Position', [1100, 200, 800, 700]);
end
    
selection = 1:length(u);

waves = cell(length(selection),1);
r = getBatchRange(app);
[~,~,unassignedInBatch] = u.getOrphanSpikes(app.t.rawSpikeSample,r);

unassignedWaves = app.rawSpikeWaves(unassignedInBatch,:);
allClust = unassignedWaves;

% if batchBool
%     for ii = 1:length(u)
%         [~, waves{ii}, ~] = u(ii).getAssignedSpikes(r);
%         allClust = cat(1,allClust, waves{ii});
%     end
% else
for ii=1:length(u)
    waves{ii} = u(selection(ii)).waves(:,:);
    allClust = cat(1,allClust, waves{ii});
end
% end

W = pca(allClust);
if size(W,2) == 0
    return;
end

unassignedF = unassignedWaves*W(:,1:6);

for ii=1:length(waves)
    if ~isempty(waves{ii})
        spikeF{ii}=waves{ii}*W(:,1:6);
    else
        spikeF{ii} = [];
    end
end

% ui elements

app.dataFeatureAx = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
    view(app.dataFeatureAx,[-5 2 5]);
    
labels = "Feature"+string(1:6);
markerSizeSldr = uislider(f,'Position',[50 90 700 3], 'Value',10, 'Limits',[1 50],...
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

posData{end+1} = posData{1}(app.dataAx.UserData.selectedUnassigned,:);
selectedBool = ROI3D(posData,1,[0,0,0; getColour(1:length(selection)); 1,0,0],...
    [".", getMarker(1:length(selection)),'o'],...
    sldr.Value*ones(size(posData)),labels);

addIdx = find(selectedBool{1});
if ~isempty(addIdx)
    [~, removeIdx, IC] = intersect(app.dataAx.UserData.selectedUnassigned,addIdx);
    addIdx(IC) = [];
    
    updateUnassignedUD(app, addIdx, removeIdx);
    updateUnassignedSelection(app);
    if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
        updateUnassignedSelectionF(app);
    end
    
end
end

