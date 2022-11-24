function [unitLines, traceLine, plottedWaves] = plotUnitInteractive(app, hTitle, hUnit, unitNum)

unitLines = [];
traceLine = [];

hTitle.Value = getUnitTitle(app, unitNum);
[plottedWavesIdx, plottedWaves] = getPlottableWaves(app, unitNum);
if isempty(plottedWaves)
    return;
end

[unitLines,traceLine,hUnit.UserData.inBatchIdx] = drawUnitLines(app, hUnit, unitNum, plottedWaves, "<");
temp = num2cell(plottedWavesIdx);
[unitLines.UserData] = temp{:};

if ~isempty(plottedWavesIdx) % if there are spikes in the unit
    set(unitLines, 'ButtonDownFcn', {@app.clickedUnitLine}) % click on spikes callback
    set(hUnit,'ButtonDownFcn',{@boxClick,app,hUnit});
end

end

%%    callback for selected spikes
function boxClick(~,evt,app,h)
if app.interactingFlag(2) ~= 0
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;
% if box corner not defined yet
if ~ishandle(app.lSelection)
    % get first box corner and draw crosshair
    app.lSelection = plot(h, u(1,1), u(1,2), 'r+', 'MarkerSize', 20);
else
    % get second box corner and draw box
    xBox = [app.lSelection.XData, u(1,1), u(1,1), app.lSelection.XData, app.lSelection.XData];
    yBox = [app.lSelection.YData, app.lSelection.YData, u(1,2), u(1,2), app.lSelection.YData];
    delete(app.lSelection);
    app.lSelection = plot(h, xBox, yBox, 'r');
    
    X = get(app.pL,'XData');
    Y = get(app.pL,'YData');
    
    selectedSpike = false(size(X));
    % select orphans inside box
    for ii = 1:length(X)
        selectedSpike(ii) = any(inpolygon(X{ii},Y{ii},xBox,yBox));
    end
    drawnow
    
    % store selected spikes
    updateAssignedSelection(app, selectedSpike)
    delete(app.lSelection);
end
end