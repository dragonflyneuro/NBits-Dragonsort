function [] = redrawMetric(app)
value = str2double(app.LeftUnitDropDown.Value);
delete(app.MetricPanel.Children);
delete(app.MetricControlGrid.Children);

if isempty(app.unitArray(value).spikeTimes)
    app.StatusLabel.Value = "Left unit is empty!";
    return;
elseif strcmp(app.MetricDropDown.Value,'Waveforms')
    scrubUnit(app,value);
elseif strcmp(app.MetricDropDown.Value,'ISI')
    showISI(app,value)
end

app.StatusLabel.Value = "Ready";
end