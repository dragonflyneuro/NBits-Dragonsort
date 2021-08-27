function [] = redrawTracePlot(app)
ht = app.dataAx;
hl = app.leftUnitAx;

c = app.currentBatch;
bl = app.t.batchLengths;
%   redraw batch time series in blue then overlay scatter for detected
%   spikes
app.StatusLabel.Value = "Redrawing data trace...";

app.pSelected = gobjects(0);
app.pSelection = gobjects(1);
app.pEvent = [];
ht.UserData.selectedUnassigned = []; % Used for storing selected orphans
cla(ht);

r = getBatchRange(app);
numSpikes = nnz(r(1) < app.t.rawSpikeSample & app.t.rawSpikeSample <= r(2));
[~, unassignedInSortingIdx] = app.unitArray.getOrphanSpikes(app.t.rawSpikeSample,r);
app.TTitle.Value = "Data trace (" + c + "/" + length(bl) + ")     Spikes assigned: " + ...
    string(numSpikes-length(unassignedInSortingIdx)) + "/" + numSpikes;

app.pRaw = plotMainData(app,ht,app.m.mainCh);
set(app.pRaw, 'ButtonDownFcn',{@boxClick,app,ht});

if app.VieweventmarkersButton.Value == 1
    app.pEvent = plotEventData(app,ht);
    for ii = 1:length(app.pEvent)
        set(app.pEvent(ii),'ButtonDownFcn',{@boxClick,app,ht});
    end
end

app.pUnassigned = plotUnassignedSpikes(app,ht,app.m.mainCh,1);
set(app.pUnassigned, 'ButtonDownFcn',{@app.clickedUnassigned,app.pUnassigned});

app.pAssigned = plotAssignedSpikes(app,ht,app.m.mainCh,hl);
set(ht,'ButtonDownFcn',{@boxClick,app,ht});

if ~isempty(app.spT) && ishandle(app.spT)
    ax = app.spT.Children.Children;
    for ii = 1:size(app.xi,1)
        cla(ax(ii));
        plotMainData(app,ax(ii),ii);
        plotUnassignedSpikes(app,ax(ii),ii,0);
        plotAssignedSpikes(app,ax(ii),ii);
        if ii ~= size(app.xi,1)
            set(ax(ii),'xtick',[]);
        else
            
        end
    end
end

if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
    delete(app.dataFeatureAx);
    dataFeatureSorter(app, app.unitArray);
end

app.StatusLabel.Value = "Ready";

end

%% CALLBACKS

% allow box selection of orphans
function boxClick(~,evt,app,h)
if isempty(app.pUnassigned)
    return;
end
if app.interactingFlag(1) ~= 0
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;
% if box corner not defined yet
if ~ishandle(app.pSelection)
    % get first box corner and draw crosshair
    app.pSelection = plot(h, u(1,1), u(1,2), 'r+', 'MarkerSize', 20);
else
    % get second box corner and draw box
    xBox = [app.pSelection.XData, u(1,1), u(1,1), app.pSelection.XData, app.pSelection.XData];
    yBox = [app.pSelection.YData, app.pSelection.YData, u(1,2), u(1,2), app.pSelection.YData];
    delete(app.pSelection);
    app.pSelection = plot(h, xBox, yBox, 'r');
    
    X = get(app.pUnassigned,'XData');
    Y = get(app.pUnassigned,'YData');
    
    % select orphans inside box
    selectedPoint = inpolygon(X,Y,xBox,yBox);
    selectedPoint = find(selectedPoint);
    drawnow
    
    % store selected orphans in UserData
    [~, removeIdx, IC] = intersect(app.dataAx.UserData.selectedUnassigned,selectedPoint);
    addIdx = selectedPoint;
    addIdx(IC) = [];
    updateUnassignedSelection(app, addIdx, removeIdx);
    if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
        updateUnassignedSelectionF(app, addIdx, removeIdx);
    end
    updateUnassignedUD(app, addIdx, removeIdx);
    delete(app.pSelection);
end
end