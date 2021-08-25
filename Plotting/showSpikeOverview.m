function [] = showSpikeOverview(u, selection, yl)

% plot unit waveforms in popout figure
subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

spikeWidth = size(u(1).waves,2);

if length(selection) > 6
    numCol = 6;
else
    numCol = length(selection);
end
sp = ceil(length(selection)/numCol);
figure('Name','Spike Overview'); set(gcf, 'Position',  [200, 200, 900, 700]);
ax = gobjects(length(selection),1);
yTemp = zeros(length(selection),2); % to match ylim later

[waves, ~, ~] = getPCs(u, selection, 600);

for ii=1:length(selection)
    ax(ii) = subplott(sp,numCol,ii);
    p = line(ax(ii), -spikeWidth:spikeWidth, waves{ii}');
    set(p, {'Color'}, num2cell(parula(size(waves{ii},1)),2));
    yTemp(ii,:) = ylim(ax(ii));
end

% edit xlim and ylim of figures to match
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
yTemp(~isinf(yl)) = yl(~isinf(yl));

for ii = 1:length(selection)
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    title(ax(ii), 'Unit '+string(selection(ii))+" "+...
        ms +" ("+length(u(selection(ii)).spikeTimes)+")",'Color',iiCmap);
    
    ylim(ax(ii), yTemp);
    ylim(yTemp);
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    xlim(ax(ii), [-spikeWidth spikeWidth]);
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

sgtitle('Units found - max 600 random spikes plotted');

end

