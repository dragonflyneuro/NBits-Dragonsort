function [unitLines, traceLine, plottedWaves] = plotUnitInteractive(app, hTitle, hUnit, uIdx)

unitLines = [];
traceLine = [];


[pWI, plottedWaves] = getPlottableWaves(app, uIdx);

if ~isempty(plottedWaves)
    templateBatches = [-app.PastbatchesTField.Value, app.FuturebatchesTField.Value];  % batches to make templates from
    r = getBatchRange(app, app.currentBatch+templateBatches);
    [dev, ~, ~] = getDevMatrix(1, app.unitArray(uIdx), plottedWaves, r, app.SpikesusedEditField.Value, app.m.sRateHz, 0);
    app.unitArray(uIdx).meanDeviation = mean(dev);
else
    app.unitArray(uIdx).meanDeviation = 0;
end

hTitle.Value = getUnitTitle(app, uIdx);

if isempty(plottedWaves)
    return;
end

[unitLines,traceLine,hUnit.UserData.inBatchIdx] = drawUnitLines(app, hUnit, uIdx, plottedWaves, "<");

if ~isempty(pWI) % if there are spikes in the unit
    temp = num2cell(pWI);
    [unitLines.UserData] = temp{:};
    set(unitLines, 'ButtonDownFcn', {@app.clickedUnitLine}) % click on spikes callback
    set(hUnit,'ButtonDownFcn',{@boxClick,app,hUnit});
end

end

%%    callback for selected spikes
function boxClick(~,evt,app,h)
if app.leftUnitAx.UserData.interactionType ~= 'n'
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;
% if box corner not defined yet
if ~ishandle(app.leftUnitSelectionBox)
    % get first box corner and draw crosshair
    app.leftUnitSelectionBox = plot(h, u(1,1), u(1,2), 'r+', 'MarkerSize', 20);
else
    % get second box corner and draw box
    xBox = [app.leftUnitSelectionBox.XData, u(1,1), u(1,1), app.leftUnitSelectionBox.XData, app.leftUnitSelectionBox.XData];
    yBox = [app.leftUnitSelectionBox.YData, app.leftUnitSelectionBox.YData, u(1,2), u(1,2), app.leftUnitSelectionBox.YData];
    delete(app.leftUnitSelectionBox);
    app.leftUnitSelectionBox = plot(h, xBox, yBox, 'r');
    
    X = get(app.leftUnitLines,'XData');
    Y = get(app.leftUnitLines,'YData');
    
    selectedSpike = false(size(X));
    % select orphans inside box
    for ii = 1:length(X)
        selectedSpike(ii) = any(inpolygon(X{ii},Y{ii},xBox,yBox));
    end
    drawnow
    
    % store selected spikes
    updateAssignedSelection(app, selectedSpike)
    delete(app.leftUnitSelectionBox);
end
end