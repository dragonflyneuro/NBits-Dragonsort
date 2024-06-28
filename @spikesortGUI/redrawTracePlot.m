function [] = redrawTracePlot(app)
ht = app.traceAx;

c = app.currentBatch;
bl = app.t.batchLengths;
%   redraw batch time series in blue then overlay scatter for detected
%   spikes
app.StatusLabel.Value = "Redrawing data trace...";

app.selectedSpikeMarkers = gobjects(0);
app.selectionBox = gobjects(1);
app.eventMarkerArr = [];
ht.UserData.selectedUnassigned = []; % Used for storing selected orphans
cla(ht);

r = getBatchRange(app);
numSpikes = nnz(r(1) < app.t.rawSpikeSample & app.t.rawSpikeSample <= r(2));
[~, unassignedInSortingIdx] = app.unitArray.getUnassignedSpikes(app.t.rawSpikeSample,r);
app.TTitle.Value = "Data trace (" + c + "/" + length(bl) + ")     Spikes assigned: " + ...
    string(numSpikes-length(unassignedInSortingIdx)) + "/" + numSpikes;

app.dataLine = plotMainData(app,ht,app.m.mainCh);
set(app.dataLine, 'ButtonDownFcn',{@boxClick,app,ht});

if app.VieweventmarkersButton.Value == 1
    app.eventMarkerArr = plotEventData(app,ht);
    for ii = 1:length(app.eventMarkerArr)
        set(app.eventMarkerArr(ii),'ButtonDownFcn',{@boxClick,app,ht});
    end
end

app.unassignedSpikeMarkers = plotUnassignedSpikes(app,ht,app.m.mainCh);
set(app.unassignedSpikeMarkers, 'ButtonDownFcn',{@app.clickedUnassigned,app.unassignedSpikeMarkers});

app.assignedSpikeMarkers = plotAssignedSpikes(app,ht,app.m.mainCh);
for ii = 1:length(app.assignedSpikeMarkers)
    set(app.assignedSpikeMarkers(ii),'ButtonDownFcn',@app.clickedAssigned);
end

set(ht,'ButtonDownFcn',{@boxClick,app,ht});

if ~isempty(app.dataAllChAx) && ishandle(app.dataAllChAx)
    ax = app.dataAllChAx.Children.Children;
    for ii = 1:size(app.xi,1)
        cla(ax(ii));
        plotMainData(app,ax(ii),ii);
        plotUnassignedSpikes(app,ax(ii),ii);
        plotAssignedSpikes(app,ax(ii),ii);
        if ii ~= size(app.xi,1)
            set(ax(ii),'xtick',[]);
        end
    end
end

if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
    dataFeatureSorter(app, app.unitArray);
end

app.StatusLabel.Value = "Ready";

end

%% CALLBACKS

% allow box selection of orphans
function boxClick(~,evt,app,h)
if isempty(app.unassignedSpikeMarkers)
    return;
end
if app.traceAx.UserData.interactionType ~= 'n'
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;
% if box corner not defined yet
if ~ishandle(app.selectionBox)
    % get first box corner and draw crosshair
    app.selectionBox = plot(h, u(1,1), u(1,2), 'r+', 'MarkerSize', 20);
else
    % get second box corner and draw box
    xBox = [app.selectionBox.XData, u(1,1), u(1,1), app.selectionBox.XData, app.selectionBox.XData];
    yBox = [app.selectionBox.YData, app.selectionBox.YData, u(1,2), u(1,2), app.selectionBox.YData];
    delete(app.selectionBox);
    app.selectionBox = plot(h, xBox, yBox, 'r');
    
    X = get(app.unassignedSpikeMarkers,'XData');
    Y = get(app.unassignedSpikeMarkers,'YData');
    
    % select orphans inside box
    selectedPoint = inpolygon(X,Y,xBox,yBox);
    selectedPoint = find(selectedPoint);
    drawnow
    
    % store selected orphans in UserData
    [~, removeIdx, IC] = intersect(app.traceAx.UserData.selectedUnassigned,selectedPoint);
    addIdx = selectedPoint;
    addIdx(IC) = [];
    
    updateUnassignedUD(app, addIdx, removeIdx);
    updateUnassignedSelection(app);
    if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
        updateUnassignedSelectionF(app);
    end
    
    delete(app.selectionBox);
end
end