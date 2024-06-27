function [] = showSpikeOverview(u, selection, yl)

% plot unit waveforms in popout figure
subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

maxNum = 800;

numCol = min([length(selection), 6]);
numRow = ceil(length(selection)/numCol);
figure('Name','Spike Overview'); set(gcf, 'Position',  [200, 200, 900, 700]);
ax = gobjects(length(selection),1);
yTemp = zeros(length(selection),2); % to match ylim later

for ii=1:length(selection)
    waves{ii} = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh);
    if ~isempty(waves{ii})
        rp = randperm(size(waves{ii},1));
        if maxNum ~= 0 && length(rp) > maxNum  % don't plot too many
            rp = rp(1:maxNum);
        end
        waves{ii} = waves{ii}(sort(rp),:);
    end
end

for ii=1:length(selection)
    spikeWidth = (size(waves{ii},2)-1)/2;
    ax(ii) = subplott(numRow,numCol,ii);
    if ~isempty(waves{ii})
        p = line(ax(ii), -spikeWidth:spikeWidth, waves{ii}');
        set(p, {'Color'}, num2cell(parula(size(waves{ii},1)),2));
    end
    yTemp(ii,:) = ylim(ax(ii));
end

% edit xlim and ylim of figures to match
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
yTemp(~isinf(yl)) = yl(~isinf(yl));

for ii = 1:length(selection)
    spikeWidth = (size(waves{ii},2)-1)/2;
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    title(ax(ii), 'Unit '+string(selection(ii))+" "+...
        ms +" ("+length(u(selection(ii)).spikeTimes)+")",'Color',iiCmap);
    
    ylim(ax(ii), yTemp);
    ylim(yTemp);
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    if spikeWidth > 0
        xlim(ax(ii), [-spikeWidth spikeWidth]);
    end
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

sgtitle("Units found - max " + string(maxNum) + " random spikes plotted");

end

