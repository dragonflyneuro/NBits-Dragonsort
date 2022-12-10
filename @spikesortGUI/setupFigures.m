function [] = setupFigures(app)
app.dataAx = axes('Parent',app.dataPanel);
xlabel(app.dataAx, 'Time (ms)')
ylabel(app.dataAx, 'Amplitude (uV)')
app.dataAx.FontName = 'Arial';
app.dataAx.Position = [0.04, 0.1, 0.95, 0.85];
app.dataAx.Toolbar.Visible = 'off';
app.dataAx.UserData.selectedUnassigned = [];
disableDefaultInteractivity(app.dataAx)

app.leftUnitAx = axes('Parent',app.LPanel);
xlabel(app.leftUnitAx, 'Samples')
ylabel(app.leftUnitAx, 'Amplitude (uV)')
app.leftUnitAx.FontName = 'Arial';
app.leftUnitAx.Position = [0.1, 0.1, 0.85, 0.86];
app.leftUnitAx.Toolbar.Visible = 'off';
app.leftUnitAx.UserData.selectedIdx = [];
app.leftUnitAx.UserData.inBatchIdx = [];
disableDefaultInteractivity(app.leftUnitAx)

app.rightUnitAx = axes('Parent',app.RPanel);
xlabel(app.rightUnitAx, 'Samples')
ylabel(app.rightUnitAx, 'Amplitude (uV)')
app.rightUnitAx.FontName = 'Arial';
app.rightUnitAx.Position = [0.1, 0.1, 0.85, 0.86];
app.rightUnitAx.Toolbar.Visible = 'off';
disableDefaultInteractivity(app.rightUnitAx)

end