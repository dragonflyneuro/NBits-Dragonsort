function [] = unitScrubber(app, n)
waves = app.unitArray(n).waves(:,:,app.unitArray(n).mainCh);

f = uifigure;
set(f, 'Position',  [300, 200, 800, 700]);
ax = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');

p = line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves');
set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
if length(p) > 1 % make future spikes invisible for now
    set(p(2:end),'Visible', 'off');
end

title(ax, "Unit "+n,'Color',getColour(n));
xlabel(ax, "Samples")
ylabel(ax, "Amplitude (uV)")

yl(1) = min(min(waves))-50; yl(2) = max(max(waves))+50;
ylim(ax, yl);

% create sliders and buttons to allow unit scrubbing and manipulation
sldr = uislider(f,'Position',[50 80 700 3], 'Value',1, 'Limits',[1 size(waves,1)],...
    'ValueChangingFcn',{@sliderMoving, p});
uibutton(f, 'Text', 'Split here', 'Position',[100 20 200 22], 'ButtonPushedFcn', {@scrubSplit, app, n, sldr, f});
uibutton(f, 'Text', 'Remove before', 'Position',[300 20 200 22], 'ButtonPushedFcn', {@scrubRemove, app, n, sldr, f, 0});
uibutton(f, 'Text', 'Remove after', 'Position',[500 20 200 22], 'ButtonPushedFcn', {@scrubRemove, app, n, sldr, f, 1});

app.StatusLabel.Value = "Ready";
end

%% callbacks
% reveal/hide spike lines as unit timeline is interacted with
function sliderMoving(~, e, p)
set(p(round(e.Value)+1:end), 'Visible', 'off');% delete(p(round(event.Value)+1:end));
set(p(1:round(e.Value)), 'Visible', 'on');
end


% split spikes before/after set timepoint in unit scrubbing window
function scrubSplit(~, ~, app, n, sld, h)
app.saveLast();
tU = app.unitArray(n).spikeTimes;
I = round(sld.Value)+1:length(tU);
app.unitArray = app.unitArray.unitSplitter(n,I);
app.redrawTracePlot();
app.redrawUnitPlots(1);
close(h)
end


% remove spikes before/after set timepoint in unit scrubbing window
function scrubRemove(~, ~, app, n, sld, h, o)
app.saveLast();
tU = app.unitArray(n).spikeTimes;
if o % choose before/after
    I = round(sld.Value)+1:length(tU);
else
    I = 1:round(sld.Value)+1;
end
app.unitArray = app.unitArray.spikeRemover(n,I);
app.redrawTracePlot();
app.redrawUnitPlots(1);
close(h)
end