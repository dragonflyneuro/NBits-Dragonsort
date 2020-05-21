function UnitButtonPushed(app, src, ~)
h = ancestor(src, 'figure');
clickType = get(h, 'SelectionType');
if strcmp(clickType, 'alt')
    if any(strcmp(app.RightUnitDropDown.Items, src.UserData))
        app.RightUnitDropDown.Value = src.UserData;
        app.RightUnitDropDownValueChanged();
    end
else
    if any(strcmp(app.LeftUnitDropDown.Items, src.UserData))
        app.LeftUnitDropDown.Value = src.UserData;
        app.LeftUnitDropDownValueChanged();
    end
end
end