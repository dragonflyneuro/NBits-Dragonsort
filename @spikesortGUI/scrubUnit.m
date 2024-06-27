function [] = scrubUnit(app, n)
app.MetricGrid.RowHeight = {22,'1x',80};
app.MetricControlGrid.RowHeight = {'1x',22};
app.MetricControlGrid.ColumnWidth = {'1x','1x','1x'};
ax = axes('Parent',app.MetricPanel);
% ax.Position = [0.1, 0.1, 0.85, 0.86];

waves = app.unitArray(n).waves(:,:,app.unitArray(n).mainCh);
p = line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves');
set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
if length(p) > 1 % make future spikes invisible for now
    set(p(2:end),'Visible', 'off');
end

xlabel(ax, "Samples")
ylabel(ax, "Amplitude (uV)")

yl(1) = min(min(waves))-50; yl(2) = max(max(waves))+50;
ylim(ax, yl);

% create sliders and buttons to allow unit scrubbing and manipulation
slider = uislider(app.MetricControlGrid, 'Value',1, 'Limits',[1 size(waves,1)],...
    'ValueChangingFcn',{@scrubSliderMoving, p});
splitButton = uibutton(app.MetricControlGrid, 'Text', 'Split here', 'ButtonPushedFcn', {@scrubSplit, app, n, slider});
removeBeforeButton = uibutton(app.MetricControlGrid, 'Text', 'Remove before', 'ButtonPushedFcn', {@scrubRemove, app, n, slider, 0});
removeAfterButton = uibutton(app.MetricControlGrid, 'Text', 'Remove after', 'ButtonPushedFcn', {@scrubRemove, app, n, slider, 1});

slider.Layout.Row = 1;
slider.Layout.Column = [1 3];
splitButton.Layout.Row = 2;
splitButton.Layout.Column = 1;
removeBeforeButton.Layout.Row = 2;
removeBeforeButton.Layout.Column = 2;
removeAfterButton.Layout.Row = 2;
removeAfterButton.Layout.Column = 3;

app.StatusLabel.Value = "Ready";
end

%% callbacks
% reveal/hide spike lines as unit timeline is interacted with
function scrubSliderMoving(~, e, p)
set(p(round(e.Value)+1:end), 'Visible', 'off');% delete(p(round(event.Value)+1:end));
set(p(1:round(e.Value)), 'Visible', 'on');
end


% split spikes before/after set timepoint in unit scrubbing window
function scrubSplit(~, ~, app, n, sld)
app.addHistory();
tU = app.unitArray(n).spikeTimes;
I = round(sld.Value)+1:length(tU);
app.unitArray = app.unitArray.unitSplitter(n,I);
app.redrawTracePlot();
app.redrawUnitPlots(1);
app.redrawMetric();
end


% remove spikes before/after set timepoint in unit scrubbing window
function scrubRemove(~, ~, app, n, sld, o)
app.addHistory();
tU = app.unitArray(n).spikeTimes;
if o % choose before/after
    I = round(sld.Value)+1:length(tU);
else
    I = 1:round(sld.Value)+1;
end
app.unitArray = app.unitArray.spikeRemover(n,I);
app.redrawTracePlot();
app.redrawUnitPlots(1);
app.redrawMetric();
end