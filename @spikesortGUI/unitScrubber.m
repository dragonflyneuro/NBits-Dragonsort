function [] = unitScrubber(app, value)
if ~any(strcmp(value,app.s.clusters))
    app.StatusLabel.Value = "Select a left unit to scrub through";
    return;
end

waves = app.s.("waves_"+value)(:,:,app.m.mainCh);

f = uifigure;
set(f, 'Position',  [300, 200, 800, 700]);
ax = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');

p = line(ax, -app.m.spikeWidth:app.m.spikeWidth, waves');
set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
if length(p) > 1 % make future spikes invisible for now
    set(p(2:end),'LineStyle', 'none');
end

title(ax, "Unit "+value,'Color',app.cmap(rem(str2double(value)-1,25)+1,:));
xlabel(ax, "Samples")
ylabel(ax, "Amplitude (uV)")

yl(1) = min(min(waves))-50; yl(2) = max(max(waves))+50;
ylim(ax, yl);

% create sliders and buttons to allow unit scrubbing and manipulation
sldr = uislider(f,'Position',[50 80 700 3], 'Value',1, 'Limits',[1 size(waves,1)],...
    'ValueChangingFcn',{@sliderMoving, p});
uibutton(f, 'Text', 'Split here', 'Position',[100 20 200 22], 'ButtonPushedFcn', {@scrubSplit, app, sldr, value, f});
uibutton(f, 'Text', 'Remove before', 'Position',[300 20 200 22], 'ButtonPushedFcn', {@scrubRemove, app, sldr, value, f, 0});
uibutton(f, 'Text', 'Remove after', 'Position',[500 20 200 22], 'ButtonPushedFcn', {@scrubRemove, app, sldr, value, f, 1});

app.StatusLabel.Value = "Ready";
end

%% callbacks
% reveal/hide spike lines as unit timeline is interacted with
function sliderMoving(~, e, p)
set(p(round(e.Value)+1:end), 'LineStyle', 'none');% delete(p(round(event.Value)+1:end));
set(p(1:round(e.Value)), 'LineStyle', '-');
end


% split spikes before/after set timepoint in unit scrubbing window
function scrubSplit(~, ~, app, sld, n, h)
app.saveLast();
tU = app.s.("unit_"+n);
I = round(sld.Value)+1:length(tU);
app.unitSplitter(n,I);
app.redrawTracePlot();
app.redrawUnitPlots();
close(h)
end


% remove spikes before/after set timepoint in unit scrubbing window
function scrubRemove(~, ~, app, sld, n, h, o)
app.saveLast();
tU = app.s.("unit_"+n);
if o % choose before/after
    I = round(sld.Value)+1:length(tU);
else
    I = 1:round(sld.Value)+1;
end
app.spikeRemover(n,I);
app.redrawTracePlot();
app.redrawUnitPlots();
close(h)
end