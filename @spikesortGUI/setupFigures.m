function [] = setupFigures(app)
app.Trace = axes('Parent',app.TracePanel);
xlabel(app.Trace, 'Time (ms)')
ylabel(app.Trace, 'Amplitude (uV)')
app.Trace.FontName = 'Arial';
app.Trace.Position = [0.04, 0.1, 0.95, 0.85];
app.Trace.Toolbar.Visible = 'off';
disableDefaultInteractivity(app.Trace)

app.LeftUnit = axes('Parent',app.LPanel);
xlabel(app.LeftUnit, 'Samples')
ylabel(app.LeftUnit, 'Amplitude (uV)')
app.LeftUnit.FontName = 'Arial';
app.LeftUnit.Position = [0.1, 0.1, 0.85, 0.86];
app.LeftUnit.Toolbar.Visible = 'off';
disableDefaultInteractivity(app.LeftUnit)

app.RightUnit = axes('Parent',app.RPanel);
xlabel(app.RightUnit, 'Samples')
ylabel(app.RightUnit, 'Amplitude (uV)')
app.RightUnit.FontName = 'Arial';
app.RightUnit.Position = [0.1, 0.1, 0.85, 0.86];
app.RightUnit.Toolbar.Visible = 'off';
disableDefaultInteractivity(app.RightUnit)

end