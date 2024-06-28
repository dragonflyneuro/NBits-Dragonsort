function [] = showImportedTemplates(u,yl)
% set up subplot function
subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

maxNum = 800;

for ii = 1:length(u)
    unitsWTemplates(ii) = ~isempty(u(ii).loadedTemplateWaves);
end
unitsWTemplates = find(unitsWTemplates);
sp = ceil(length(unitsWTemplates)/2);

f = figure; set(f, 'Position',  [200, 200, 900, 700]);
ax = gobjects(length(unitsWTemplates)*2,1);
yTemp = zeros(length(unitsWTemplates)*2,2); % to align y axis limits later

for ii = 1:length(unitsWTemplates)
    uIdx = unitsWTemplates(ii);
    ax(2*ii-1) = subplott(sp,4,2*ii-1);
    ax(2*ii) = subplott(sp,4,2*ii);
    ms = getMarker(uIdx);
    iiCmap = getColour(uIdx);
    
    % plot random selection of up to 600 waveforms in unit
    waves = u(uIdx).waves(:,:,u(uIdx).mainCh);
    if ~isempty(waves)
        spikeWidth = (size(waves,2)-1)/2;
        rp = randperm(size(waves,1));
        if length(rp) > maxNum
            rp = rp(1:maxNum);
        end
        waves = waves(sort(rp),:,:);
        p = line(ax(2*ii), -spikeWidth:spikeWidth, waves');
        set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
    end
    
    % plot all initialiser template waves for the unit
    waves = u(uIdx).loadedTemplateWaves(:,:,u(uIdx).mainCh);
    if ~isempty(waves)
        spikeWidth = (size(waves,2)-1)/2;
        p = line(ax(2*ii-1), -spikeWidth:spikeWidth, waves');
        set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
    end
    
    yTemp(2*ii,:) = ylim(ax(2*ii));
    yTemp(2*ii-1,:) = ylim(ax(2*ii-1));
    title(ax(2*ii), 'Unit '+string(uIdx)+" "+ ms +...
        " ("+length(u(uIdx).spikeTimes)+")",'Color',iiCmap);
    title(ax(2*ii-1), 'Template '+ string(ii));
end

% edit xlim and ylim of figures to match
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
yTemp(~isinf(yl)) = yl(~isinf(yl));

for ii = 1:length(ax)
    ylim(ax(ii), yTemp);
    ylim(yTemp); %axis square;
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

sgtitle("Units found - max " + string(maxNum) + " random spikes plotted");

end