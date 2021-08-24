function [unitLines, traceLine, plottedWaves] = plotUnitInteractive(app, hTitle, hUnit, unitNum)

unitLines = [];
traceLine = [];
app.plottedWavesIdx = [];

hTitle.Value = getUnitTitle(app, unitNum);
[app.plottedWavesIdx, plottedWaves] = getPlottableWaves(app, unitNum);
if isempty(plottedWaves)
    return;
end

[unitLines,traceLine,hUnit.UserData{2}] = drawUnitLines(app, hUnit, unitNum, plottedWaves, "<");

if ~isempty(app.plottedWavesIdx) % if there are spikes in the unit
    set(unitLines, 'ButtonDownFcn', {@lineSelected, app, app.plottedWavesIdx, hUnit}) % click on spikes callback
    set(hUnit,'ButtonDownFcn',{@boxClick,app,app.plottedWavesIdx,hUnit});
end

end

%%    callback for selected spikes
function boxClick(~,evt,app, w, h)
if isempty(app.pUnassigned)
    return;
end
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
    
    selectedLine = false(size(X));
    % select orphans inside box
    for ii = 1:length(X)
        selectedLine(ii) = any(inpolygon(X{ii},Y{ii},xBox,yBox));
    end
    selectedLine = find(selectedLine);
    selectedSpike = w(selectedLine);
    drawnow
    
    % store selected spikes in UserData
    for qq = 1:length(selectedLine)
        alreadySelectedBool = ismember(h.UserData{1},selectedSpike(qq));
        if ~any(alreadySelectedBool)
            app.pL(selectedLine(qq)).LineStyle = ':';
            h.UserData{1} = [h.UserData{1}, selectedSpike(qq)];
        else
            app.pL(selectedLine(qq)).LineStyle = '-';
            h.UserData{1}(alreadySelectedBool) = [];
        end
    end
    delete(app.lSelection);
end
end

function lineSelected(src, ~, app, w, h)
if app.interactingFlag(2) ~= 0
    return;
end
selectedSpike = w(app.pL == src);
if strcmp(src.LineStyle, ':')
    src.LineStyle = '-';
    h.UserData{1}(h.UserData{1} ~= selectedSpike) = [];
else
    src.LineStyle = ':';
    h.UserData{1} = [h.UserData{1}, selectedSpike];
end

end