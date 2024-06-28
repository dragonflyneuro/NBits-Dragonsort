function [] = setupFigures(app)
xlabel(app.traceAx, 'Time (ms)')
ylabel(app.traceAx, 'Amplitude (uV)')
app.traceAx.FontName = 'Arial';
app.traceAx.Position = [0.04, 0.1, 0.95, 0.85];
app.traceAx.Toolbar.Visible = 'off';
app.traceAx.UserData.selectedUnassigned = [];
app.traceAx.UserData.interactionType = 'n';
disableDefaultInteractivity(app.traceAx)

xlabel(app.leftUnitAx, 'Samples')
ylabel(app.leftUnitAx, 'Amplitude (uV)')
app.leftUnitAx.FontName = 'Arial';
app.leftUnitAx.Position = [0.1, 0.1, 0.85, 0.86];
app.leftUnitAx.Toolbar.Visible = 'off';
app.leftUnitAx.UserData.selectedIdx = [];
app.leftUnitAx.UserData.inBatchIdx = [];
app.leftUnitAx.UserData.interactionType = 'n';
disableDefaultInteractivity(app.leftUnitAx)

xlabel(app.rightUnitAx, 'Samples')
ylabel(app.rightUnitAx, 'Amplitude (uV)')
app.rightUnitAx.FontName = 'Arial';
app.rightUnitAx.Position = [0.1, 0.1, 0.85, 0.86];
app.rightUnitAx.Toolbar.Visible = 'off';
disableDefaultInteractivity(app.rightUnitAx)

app.Metrics.gridArr = [app.MetricGrid_1, app.MetricGrid_2, app.MetricGrid_3, app.MetricGrid_4];
app.Metrics.controlGridArr = [app.MetricControlGrid_1, app.MetricControlGrid_2, app.MetricControlGrid_3, app.MetricControlGrid_4];
app.Metrics.dropDownArr = [app.MetricDropDown_1, app.MetricDropDown_2, app.MetricDropDown_3, app.MetricDropDown_4];
app.Metrics.panelArr = [app.MetricPanel_1, app.MetricPanel_2, app.MetricPanel_3, app.MetricPanel_4];
app.Metrics.axArr = gobjects(4);
app.Metrics.controlCell = {};
for ii = 1:length(app.Metrics.dropDownArr)
    app.Metrics.dropDownArr(ii).UserData = ii;
    app.Metrics.dropDownArr(ii).Items = {'None',...
        'ISI (left)',...
        'ISI (right)',...
        'Waveforms (left)',...
        'Cross-correlogram',...
        'Temporal Stability (global)',...
        'Deviation Template',...
        'Mean'};
end

end