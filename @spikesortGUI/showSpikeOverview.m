function [] = showSpikeOverview(app, u, selection)

% plot unit waveforms in popout figure
subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

drawnow

if length(selection) > 6
    numCol = 6;
else
    numCol = length(selection);
end
sp = ceil(length(selection)/numCol);
figure; set(gcf, 'Position',  [200, 200, 900, 700]);
ax = gobjects(length(selection),1);
yTemp = zeros(length(selection),2); % to match ylim later

[waves, ~, ~] = getPCs(u, selection, 600);

for ii=1:length(selection)
    ax(ii) = subplott(sp,numCol,ii);
    p = line(ax(ii), -app.m.spikeWidth:app.m.spikeWidth, waves{ii}');
    set(p, {'Color'}, num2cell(parula(size(waves{ii},1)),2));
    yTemp(ii,:) = ylim(ax(ii));
end

% edit xlim and ylim of figures to match
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];

if ~isinf(app.yLimLowField.Value)
    yTemp(1) = app.yLimLowField.Value;
end
if ~isinf(app.yLimHighField.Value)
    yTemp(2) = app.yLimHighField.Value;
end

for ii = 1:length(selection)
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    ms = getMarker(size(app.cmap,1), ii);
    title(ax(ii), 'Unit '+string(selection(ii))+" "+...
        ms +" ("+length(u(selection(ii)).spikeTimes)+")",'Color',iiCmap);
    
    ylim(ax(ii), yTemp);
    ylim(yTemp);
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    xlim(ax(ii), [-app.m.spikeWidth app.m.spikeWidth]);
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

sgtitle('Units found - max 600 random spikes plotted');

end

