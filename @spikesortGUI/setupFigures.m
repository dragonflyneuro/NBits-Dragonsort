function [] = setupFigures(app)
app.dataPanel.AutoResizeChildren = 'off';
xlabel(app.traceAx, 'Time (ms)')
ylabel(app.traceAx, 'Amplitude (uV)')
app.traceAx.FontName = 'Arial';
app.traceAx.Units = 'normalized';
app.traceAx.Position = [0.03, 0.1, 0.96, 0.85];
app.traceAx.Toolbar.Visible = 'off';
app.traceAx.UserData.selectedUnassigned = [];
app.traceAx.UserData.interactionType = 'n';
disableDefaultInteractivity(app.traceAx)

app.LPanel.AutoResizeChildren = 'off';
xlabel(app.leftUnitAx, 'Samples')
app.leftUnitAx.FontName = 'Arial';
app.leftUnitAx.Units = 'normalized';
app.leftUnitAx.Position = [0.05, 0.1, 0.92, 0.85];
app.leftUnitAx.Toolbar.Visible = 'off';
app.leftUnitAx.UserData.selectedIdx = [];
app.leftUnitAx.UserData.inBatchIdx = [];
app.leftUnitAx.UserData.interactionType = 'n';
disableDefaultInteractivity(app.leftUnitAx)

app.RPanel.AutoResizeChildren = 'off';
xlabel(app.rightUnitAx, 'Samples')
app.rightUnitAx.FontName = 'Arial';
app.rightUnitAx.Units = 'normalized';
app.rightUnitAx.Position = [0.05, 0.1, 0.92, 0.85];
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
        'Templates (batch)',...
        };
end

end