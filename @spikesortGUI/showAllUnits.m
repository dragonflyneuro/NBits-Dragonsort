function [] = showAllUnits(app, u, selection)

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

[waves, ~, PC] = getPCs(u, selection);
for ii=1:length(waves)
    clusPC{ii}=waves{ii}*PC(:,1:6);
end

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
    ylim(ax(ii), yTemp);
    ylim(yTemp);
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    xlim(ax(ii), [-app.m.spikeWidth app.m.spikeWidth]);
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

sgtitle('Units found - max 600 random spikes plotted');

%PCA view-interactive
f = uifigure;
set(f, 'Position',  [1100, 200, 800, 700]);
axPC = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(axPC,[-5 2 5]);

for ii=1:length(selection)
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    ms = getMarker(size(app.cmap,1), ii);
    title(ax(ii), 'Unit '+string(selection(ii))+" "+...
        ms +" ("+length(u(selection(ii)).spikeTimes)+")",'Color',iiCmap);
    if ~isempty(u(selection(ii)).waves)
        scatter3(axPC,clusPC{ii}(:,1),clusPC{ii}(:,2),clusPC{ii}(:,3),20,...
            repmat(iiCmap,size(clusPC{ii},1),1),"Marker",ms); % 3D PCA plot
    end
end
xlabel(axPC,"PC1"); ylabel(axPC,"PC2"); zlabel(axPC,"PC3");
title(axPC,'Units found - PCs view');
legend(axPC,"Unit " + selection);

markerSizeSldr = uislider(f,'Position',[50 80 700 3], 'Value',20, 'Limits',[1 200],...
    'ValueChangingFcn',{@sliderMoving, axPC});
axisChoice(1) = uidropdown(f,'Items',{'PC1','PC2','PC3','PC4','PC5','PC6'}, 'Value','PC1',...
    'Position',[100 20 200 22]);
axisChoice(2) = uidropdown(f,'Items',{'PC1','PC2','PC3','PC4','PC5','PC6'}, 'Value','PC2',...
    'Position',[300 20 200 22]);
axisChoice(3) = uidropdown(f,'Items',{' ','PC1','PC2','PC3','PC4','PC5','PC6'}, 'Value','PC3',...
    'Position',[500 20 200 22]);
for ii = 1:3
    set(axisChoice(ii),'ValueChangedFcn', {@updateView, app, clusPC, u, selection, axPC, axisChoice, markerSizeSldr});
end

end

%% callbacks
function sliderMoving(~, e, h)
for ii = 1:length(h.Children)
    h.Children(ii).SizeData = e.Value;
end
end

function updateView(~, ~, app, clusPC, u, sel, h, axisChoice, sldr)
[caz,cel] = view(h);
cla(h)

for ii=1:length(sel)
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    ms = getMarker(size(app.cmap,1), ii);
    if ~isempty(u(sel(ii)).waves)
        if axisChoice(3).Value ~= ' '
            for jj = 1:length(axisChoice)
                choice(jj) = sscanf(axisChoice(jj).Value,'PC%d');
            end
            scatter3(h, clusPC{ii}(:,choice(1)),clusPC{ii}(:,choice(2)),clusPC{ii}(:,choice(3)),sldr.Value,...
                repmat(iiCmap,size(clusPC{ii},1),1),"Marker",ms);
            if caz == 0 && cel == 90
                view(h,[-5 2 5]);
            end
        else
            for jj = 1:2
                choice(jj) = sscanf(axisChoice(jj).Value,'PC%d');
            end
            scatter(h, clusPC{ii}(:,choice(1)),clusPC{ii}(:,choice(2)),sldr.Value,...
                repmat(iiCmap,size(clusPC{ii},1),1),"Marker",ms);
            view(h,2);
        end
    end
end

xlabel(h,axisChoice(1).Value); ylabel(h,axisChoice(1).Value);
if axisChoice(3).Value ~= ' '
    zlabel(h,axisChoice(3).Value);
end

end