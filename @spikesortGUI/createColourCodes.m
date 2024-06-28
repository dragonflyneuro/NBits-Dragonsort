function h = createColourCodes(app)
app.ColourGrid.ColumnWidth = repmat("1x",max([20,length(app.LeftUnitDropDown.Items)]),1);
for ii = str2double(app.LeftUnitDropDown.Items)
    h(ii) = uibutton(app.ColourGrid, 'push', 'Text', string(ii),'ButtonPushedFcn', ...
        {@colourButtonPushed,app,ii});
    h(ii).BackgroundColor = getColour(ii);
    h(ii).Layout.Column = ii;
end
end

function [] = colourButtonPushed(~, ~, app,uIdx)
pause(0.25);
if strcmpi(get(app.UIBase, 'SelectionType'), 'open')
    app.RightUnitDropDown.Value = string(uIdx);
    app.redrawUnitPlots(2);
    selection = contains({app.Metrics.dropDownArr.Value},'(left)')...
        | contains({app.Metrics.dropDownArr.Value},'(global)');
    app.redrawMetric(find(~selection));
else
    app.LeftUnitDropDown.Value = string(uIdx);
    app.redrawUnitPlots(1);
    selection = contains({app.Metrics.dropDownArr.Value},'(right)')...
        | contains({app.Metrics.dropDownArr.Value},'(global)');
    app.redrawMetric(find(~selection));
end
end