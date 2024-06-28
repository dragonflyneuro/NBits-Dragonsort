function [] = scrubUnit(app, uiPos)
uIdx = str2double(app.LeftUnitDropDown.Value);
isSameMetric = strcmp(app.Metrics.controlGridArr(uiPos).UserData, ...
    app.Metrics.dropDownArr(uiPos).Value);

if isSameMetric
    delete(app.Metrics.controlGridArr(uiPos).Children);
    ax = app.Metrics.panelArr(uiPos).Children;
    cla(ax);
else
    delete(app.Metrics.panelArr(uiPos).Children);
    delete(app.Metrics.controlGridArr(uiPos).Children);

    app.Metrics.gridArr(uiPos).RowHeight = {22,'1x',80};
    app.Metrics.controlGridArr(uiPos).RowHeight = {'1x',22};
    app.Metrics.controlGridArr(uiPos).ColumnWidth = {'1x','1x','1x'};
    ax = axes('Parent',app.Metrics.panelArr(uiPos));
    app.Metrics.controlGridArr(uiPos).UserData = app.Metrics.dropDownArr(uiPos).Value;
end

waves = app.unitArray(uIdx).waves(:,:,app.unitArray(uIdx).mainCh);
waveLines = line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves');
set(waveLines, {'Color'}, num2cell(parula(size(waves,1)),2));
if length(waveLines) > 1 % make future spikes invisible for now
    set(waveLines(2:end),'Visible', 'off');
end

xlabel(ax, "Samples")
ylabel(ax, "Amplitude (uV)")

yl(1) = min(min(waves))-50; yl(2) = max(max(waves))+50;
ylim(ax, yl);

% create sliders and buttons to allow unit scrubbing and manipulation
slider = uislider(app.Metrics.controlGridArr(uiPos), 'Value',1,...
    'Limits',[1 size(waves,1)],'ValueChangingFcn',{@scrubSliderMoving, waveLines});
slider.Layout.Row = 1;
slider.Layout.Column = [1 3];

splitButton = uibutton(app.Metrics.controlGridArr(uiPos),...
    'Text', 'Split here', 'ButtonPushedFcn', {@scrubSplit, app, uIdx, slider});
splitButton.Layout.Row = 2;
splitButton.Layout.Column = 1;

removeBeforeButton = uibutton(app.Metrics.controlGridArr(uiPos),...
    'Text', 'Remove before', 'ButtonPushedFcn', {@scrubRemove, app, uIdx, slider, 0});
removeBeforeButton.Layout.Row = 2;
removeBeforeButton.Layout.Column = 2;

removeAfterButton = uibutton(app.Metrics.controlGridArr(uiPos),...
    'Text', 'Remove after', 'ButtonPushedFcn', {@scrubRemove, app, uIdx, slider, 1});
removeAfterButton.Layout.Row = 2;
removeAfterButton.Layout.Column = 3;
end

%% callbacks
% reveal/hide spike lines as unit timeline is interacted with
function scrubSliderMoving(~, event, waveLines)
set(waveLines(round(event.Value)+1:end), 'Visible', 'off');% delete(p(round(event.Value)+1:end));
set(waveLines(1:round(event.Value)), 'Visible', 'on');
end


% split spikes before/after set timepoint in unit scrubbing window
function scrubSplit(~, ~, app, uIdx, slider)
app.addHistory();
tU = app.unitArray(uIdx).spikeTimes;
I = round(slider.Value)+1:length(tU);
app.unitArray = app.unitArray.unitSplitter(uIdx,I);
app.redrawTracePlot();
app.redrawUnitPlots(1);
app.redrawMetric();
end


% remove spikes before/after set timepoint in unit scrubbing window
function scrubRemove(~, ~, app, uIdx, slider, opDirection)
app.addHistory();
tU = app.unitArray(uIdx).spikeTimes;
if opDirection % choose before/after
    I = round(slider.Value)+1:length(tU);
else
    I = 1:round(slider.Value)+1;
end
app.unitArray = app.unitArray.spikeRemover(uIdx,I);
app.redrawTracePlot();
app.redrawUnitPlots(1);
app.redrawMetric();
end