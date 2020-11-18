function [] = showLoadedTemplates(app)
% set up subplot function
subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);
app.StatusLabel.Value = "Plotting units with their templates...";
drawnow

for ii = 1:length(app.unitArray)
    unitsWTemplates(ii) = ~isempty(app.unitArray(ii).loadedTemplateWaves);
end
unitsWTemplates = find(unitsWTemplates);
sp = ceil(length(unitsWTemplates)/2);

f = figure; set(f, 'Position',  [200, 200, 900, 700]);
ax = gobjects(length(unitsWTemplates)*2,1);
yTemp = zeros(length(unitsWTemplates)*2,2); % to align y axis limits later

for ii=unitsWTemplates
    ax(2*ii-1) = subplott(sp,4,2*ii-1);
    ax(2*ii) = subplott(sp,4,2*ii);
    ms = getMarker(size(app.cmap,1), ii);
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    
    % plot random selection of up to 600 waveforms in unit
    waves = app.unitArray(ii).waves(:,:,app.unitArray(ii).mainCh);
    if ~isempty(waves)
        rp = randperm(size(waves,1));
        if length(rp) > 600
            rp = rp(1:600);
        end
        waves = waves(sort(rp),:,:);
        p = line(ax(2*ii), -app.m.spikeWidth:app.m.spikeWidth, waves');
        set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
    end
    
    % plot all initialiser template waves for the unit
    waves = app.unitArray(ii).loadedTemplateWaves(:,:,app.unitArray(ii).mainCh);
    if ~isempty(waves)
        p = line(ax(2*ii-1), -app.m.spikeWidth:app.m.spikeWidth, waves');
        set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
    end
    
    yTemp(2*ii,:) = ylim(ax(2*ii));
    yTemp(2*ii-1,:) = ylim(ax(2*ii-1));
    title(ax(2*ii), 'Unit '+string(ii)+" "+ ms +...
        " ("+length(app.unitArray(ii).spikeTimes)+")",'Color',iiCmap);
    title(ax(2*ii-1), 'Template '+ string(ii));
end

% edit xlim and ylim of figures to match
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];

if ~isinf(app.yLimLowField.Value)
    yTemp(1) = app.yLimLowField.Value;
end
if ~isinf(app.yLimHighField.Value)
    yTemp(2) = app.yLimHighField.Value;
end

for ii = 1:length(ax)
    ylim(ax(ii), yTemp);
    ylim(yTemp); %axis square;
    xlim(ax(ii), [-app.m.spikeWidth app.m.spikeWidth]);
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end
sgtitle('Units with their loaded templates - max 600 random spikes plotted');

app.StatusLabel.Value = "Ready";
end