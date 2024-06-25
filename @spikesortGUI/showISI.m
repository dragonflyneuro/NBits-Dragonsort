function [] = showISI(app, n)
% plot number of spikes in each unit in each batch
app.MetricGrid.RowHeight = {22,'1x',44};
app.MetricControlGrid.RowHeight = {'1x','1x'};
app.MetricControlGrid.ColumnWidth = {'1x','1x'};
ax = axes('Parent',app.MetricPanel);
% ax.Position = [0.1, 0.1, 0.85, 0.86];

bE = 0:0.5:100;
ISI = diff(app.unitArray(n).spikeTimes*1e3/app.m.sRateHz);

histogram(ax, ISI,bE,'Linestyle','none');
xlabel(ax,'ISI (ms)')
ylabel(ax,'Frequency per bin')
% xticks(ax,0:10:100);
xlim(ax,[0 100]);

violationThrField = uieditfield(app.MetricControlGrid,"numeric","Limits",[0 inf], ...
    "Value",1);
violationThrField.Layout.Column = 2;
violationThrField.Layout.Row = 2;
autosplitButton = uibutton(app.MetricControlGrid, 'Text', 'Autosplit violations below:',...
    'ButtonPushedFcn', {@splitISI, app, n, violationThrField, ISI});
autosplitButton.Layout.Column = 1;
autosplitButton.Layout.Row = 2;

violationCountLabel = uilabel(app.MetricControlGrid, 'text');
violationCountLabel.Layout.Row = 1;
violationCountLabel.Layout.Column = [1 2];
violationCountLabel.Text = "There are " + string(sum(ISI < 1)) + " spikes with ISI of under 1ms";


end
%% callbacks
% split violating spikes
function splitISI(~, ~, app, n, v, ISI)
violations = ISI < v.Value;
if any(violations)
    app.unitArray = app.unitArray.unitSplitter(n,violations);
end
app.updateDropdown();
app.standardUpdate;
end