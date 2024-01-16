function [] = showISI(app, n)
% plot number of spikes in each unit in each batch
f = uifigure('Name','ISI Histogram');
set(f, 'Position',  [1100, 200, 800, 700]);
ax = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
title(ax, "ISI histogram for Unit "+n,'Color',getColour(n));

bE = 0:0.5:100;
ISI = diff(app.unitArray(n).spikeTimes*1e3/app.m.sRateHz);

histogram(ax, ISI,bE,'Linestyle','none');
xlabel(ax,'ISI (ms)')
ylabel(ax,'Frequency per bin')
% xticks(ax,0:10:100);
xlim(ax,[0 100]);

violationThrField = uieditfield(f,"numeric","Limits",[0 inf], ...
    "Value",1,'Position',[300 20 200 22]);
uibutton(f, 'Text', 'Autosplit violations below:', 'Position',[300 44 200 22],...
    'ButtonPushedFcn', {@splitISI, app, n, f, violationThrField, ISI});

end
%% callbacks
% split violating spikes
function splitISI(~, ~, app, n, f, v, ISI)
violations = ISI < v.Value;
if any(violations)
    I = app.unitArray(n).spikeTimes([0 violations]);
    app.saveLast();
    app.unitArray = app.unitArray.unitSplitter(n,I);
end
app.redrawTracePlot();
app.redrawUnitPlots(1);
close(f)
end