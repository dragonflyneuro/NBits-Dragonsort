function [] = redrawUnitPlots(app, varargin)
if nargin > 1
    updateFlag = varargin{1};
else
    updateFlag = 0;
end

app.StatusLabel.Value = "Updating unit figures...";
drawnow

if updateFlag == 0 || updateFlag == 1
    set(app.LeftUnit,'UserData', {[],[]}); % reset selected spikes in left unit
    set(app.LeftUnit,'ButtonDownFcn',[]);
    u = str2double(app.LeftUnitDropDown.Value);
    delete(app.lSelection); delete(app.pL); delete(app.pTL);
    [app.pL, app.pTL, waves] = plotUnitInteractive(app, app.LTitle, app.LeftUnit, u);
    if ~isempty(app.spL) && ishandle(app.spL)
        app.spL = plotMultiUnit(app, app.spL, u, waves);
    end
    app.LeftUnitDropDown.FontColor = getColour(u);
end

if updateFlag == 0 || updateFlag == 2
    u = str2double(app.RightUnitDropDown.Value);
    delete(app.pR); delete(app.pTR);
    [app.pR, app.pTR, waves] = plotUnit(app, app.RTitle, app.RightUnit, u);
    if ~isempty(app.spR) && ishandle(app.spR)
        app.spR = plotMultiUnit(app, app.spR, u, waves);
    end
    app.RightUnitDropDown.FontColor = getColour(u);
end

app.StatusLabel.Value = "Ready";

end