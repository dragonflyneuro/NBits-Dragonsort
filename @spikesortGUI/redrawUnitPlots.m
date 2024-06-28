function [] = redrawUnitPlots(app, varargin)
if nargin > 1
    updateFlag = varargin{1};
else
    updateFlag = 0;
end

app.StatusLabel.Value = "Updating unit figures...";
drawnow

if updateFlag == 0 || updateFlag == 1
    app.leftUnitAx.UserData.selectedIdx = [];
    app.leftUnitAx.UserData.inBatchIdx = [];
    % set(app.leftUnitAx,'ButtonDownFcn',[]);
    uIdx = str2double(app.LeftUnitDropDown.Value);
    delete(app.leftUnitSelectionBox); delete(app.leftUnitLines); delete(app.leftUnitSpikeMarkers); cla(app.leftUnitAx);
    [app.leftUnitLines, app.leftUnitSpikeMarkers, waves] = plotUnitInteractive(app, app.LTitle, app.leftUnitAx, uIdx);
    if ~isempty(app.leftUnitAllChAx) && ishandle(app.leftUnitAllChAx)
        app.leftUnitAllChAx = plotMultiUnit(app, app.leftUnitAllChAx, uIdx, waves);
    end
    app.LeftUnitDropDown.FontColor = getColour(uIdx);
end

if updateFlag == 0 || updateFlag == 2
    uIdx = str2double(app.RightUnitDropDown.Value);
    delete(app.rightUnitLines); delete(app.rightUnitSpikeMarkers);
    [app.rightUnitLines, app.rightUnitSpikeMarkers, waves] = plotUnit(app, app.RTitle, app.rightUnitAx, uIdx);
    if ~isempty(app.rightUnitAllChAx) && ishandle(app.rightUnitAllChAx)
        app.rightUnitAllChAx = plotMultiUnit(app, app.rightUnitAllChAx, uIdx, waves);
    end
    app.RightUnitDropDown.FontColor = getColour(uIdx);
end

app.StatusLabel.Value = "Ready";

end