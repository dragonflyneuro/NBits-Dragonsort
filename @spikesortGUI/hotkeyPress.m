function [] = hotkeyPress(app, ~, event)
if strcmpi(event.Key, 'leftbracket')
    answer = inputdlg("go to unit:","go to unit");
    if ismember(string(answer), app.LeftUnitDropDown.Items)
        app.LeftUnitDropDown.Value = answer;
        app.redrawUnitPlots2(1);
    end
elseif strcmpi(event.Key, 'rightbracket')
    answer = inputdlg("go to unit:","go to unit");
    if ismember(string(answer), app.RightUnitDropDown.Items)
        app.RightUnitDropDown.Value = answer;
        app.redrawUnitPlots(2);
    end
end
app.UIBase;
end