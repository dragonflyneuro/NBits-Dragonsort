function [] = showAllUnits(app, u, selection)

% plot unit waveforms in popout figure
subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

drawnow

allClust = [];
if length(selection) > 6
    numCol = 6;
else
    numCol = length(selection);
end
sp = ceil(length(selection)/numCol);
figure; set(gcf, 'Position',  [200, 200, 900, 700]);
ax = gobjects(length(selection),1);
yTemp = zeros(length(selection),2); % to match ylim later

for ii=1:length(selection)
    ax(ii) = subplott(sp,numCol,ii);
    waves = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh);
    if ~isempty(waves)
        allClust = cat(1,allClust, waves);
        rp = randperm(size(waves,1));
        if length(rp) > 600 % don't plot too many
            rp = rp(1:600);
        end
        waves = waves(sort(rp),:,:);
        p = line(ax(ii), -app.m.spikeWidth:app.m.spikeWidth, waves');
        set(p, {'Color'}, num2cell(parula(size(waves,1)),2));
        yTemp(ii,:) = ylim(ax(ii));
    end
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
    ylim(ax(ii), yTemp);
    ylim(yTemp);
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    xlim(ax(ii), [-app.m.spikeWidth app.m.spikeWidth]);
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

sgtitle('Units found - max 600 random spikes plotted');

PC = pca(allClust);

figure; set(gcf, 'Position',  [1100, 200, 700, 600]);

for ii=1:length(selection)
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    ms = getMarker(size(app.cmap,1), ii);
    title(ax(ii), 'Unit '+string(selection(ii))+" "+...
        ms +" ("+length(u(selection(ii)).spikeTimes)+")",'Color',iiCmap);
    if ~isempty(u(selection(ii)).waves)
        clusPC = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh)*PC(:,1:3);
        scatter3(clusPC(:,1),clusPC(:,2),clusPC(:,3),20,repmat(iiCmap,size(clusPC,1),1),"Marker",ms); % 3D PCA plot
    end
    hold on;
end
xlabel("PC1"); ylabel("PC2"); zlabel("PC3");
title('Units found - PCs view');
legend("Unit " + selection);
end