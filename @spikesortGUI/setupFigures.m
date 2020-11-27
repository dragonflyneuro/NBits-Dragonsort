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

% subplots prettyfying for all channel plotting
%    allChSubplots
%    subplotTrace = @(m,n,p) subtightplot (m, n, p, [0 0.02], [0.05 0.04], [0.02 0.02], 'Parent', app.AllChTTab);
%    subplotTempR = @(m,n,p) subtightplot (m, n, p, [0.02 0.02], [0.05 0.04], [0.05 0.05], 'Parent', app.AllChRTab);
%    subplotTempL = @(m,n,p) subtightplot (m, n, p, [0.02 0.02], [0.05 0.04], [0.05 0.05], 'Parent', app.AllChLTab);
%             for ii = 1:4
%                 app.spT = tight_subplot(4,1, [0 0.02], [0.05 0.04], [0.02 0.02], app.AllChTTab);
%                 app.spR = tight_subplot(2,2, [0 0.02], [0.05 0.04], [0.02 0.02], app.AllChRTab);
%                 app.spL = tight_subplot(2,2, [0 0.02], [0.05 0.04], [0.02 0.02], app.AllChLTab);
%                 if ii == 1 || ii == 2
%                     set(app.spR(ii), 'XTickMode', 'manual', 'XTick', []);
%                     set(app.spL(ii), 'XTickMode', 'manual', 'XTick', []);
%                     set(app.spT(ii), 'XTickMode', 'manual', 'XTick', [], 'XColor', [0.5 0.5 0.5]);
%                 end
%                 if ii == 2 || ii == 4
%                     set(app.spR(ii), 'YTickMode', 'manual', 'YTick', []);
%                     set(app.spL(ii), 'YTickMode', 'manual', 'YTick', []);
%                 end
%                 if ii == 3
%                     set(app.spT(ii), 'XTickMode', 'manual', 'XTick', [], 'XColor', [0.5 0.5 0.5]);
%                 end
%                 hold(app.spT(ii), 'on');
%             end
end