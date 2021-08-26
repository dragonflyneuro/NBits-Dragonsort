function f = tracePCASorter(app, u)

selection = 1:length(u);

waves = cell(length(selection),1);

[~,~,orphansInBatch] = u.getOrphanSpikes(app.t.rawSpikeSample,getBatchRange(app));
orphanWaves = app.rawSpikeWaves(orphansInBatch,:);
allClust = orphanWaves;

for ii=1:length(u)
    waves{ii} = u(selection(ii)).waves(:,:);
    allClust = cat(1,allClust, u(selection(ii)).waves(:,:));
end

PC = pca(allClust);

for ii=1:length(waves)
    spikePC{ii}=waves{ii}*PC(:,1:6);
end

orphanPC = orphanWaves*PC(:,1:6);

%PCA view-interactive
f = uifigure('Name','PCA Overview');
set(f, 'Position',  [1100, 200, 800, 700]);
axPC = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(axPC,[-5 2 5]);

% ui elements
for ii = 1:3
    axisChoice(ii) = uidropdown(f,'Items', labels, 'Value',labels(ii),...
        'Position',[100+200*(ii-1) 30 200 22],'UserData',ii);
end
for ii = 1:3
    set(axisChoice(ii),'ValueChangedFcn', {@updateView, axPC, spikePC, u, selection, axisChoice, markerSizeSldr});
end
axisChoice(3).Items = [axisChoice(3).Items," "];

markerSizeSldr = uislider(f,'Position',[50 90 700 3], 'Value',20, 'Limits',[1 200],...
    'ValueChangingFcn',{@sliderMoving, axPC});

uibutton(f,'Position',[350 5 100 22], 'Text','ROI Select',...
    'ButtonPushedFcn',{@ROIClick, app, markerSizeSldr, axisChoice, [{orphanPC},spikePC],selection});

for ii=1:length(selection)
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    if ~isempty(u(selection(ii)).waves)
        scatter3(axPC,spikePC{ii}(:,1),spikePC{ii}(:,2),spikePC{ii}(:,3),20,...
            repmat(iiCmap,[size(spikePC{ii},1),1]),"Marker",ms); % 3D PCA plot
    end
end
if ~isempty(orphanPC)
    app.pUnassignedPC = scatter3(axPC,orphanPC(:,1),orphanPC(:,2),orphanPC(:,3),20,...
        repmat([0 0 0],[size(orphanPC,1),1]),"Marker",'.'); % 3D PCA plot
    set(app.pUnassignedPC, 'ButtonDownFcn',{@clickedUnassigned,app,f});
end

labels = "PC"+string(1:6);
xlabel(axPC,labels(1)); ylabel(axPC,labels(2)); zlabel(axPC,labels(3));
title(axPC,'Units found - PCs view');
legend(axPC,"Unit " + selection);

end

%% callbacks
% function sliderMoving(~, e, h)
% for ii = 1:length(h.Children)
%     h.Children(ii).SizeData = e.Value;
% end
% end
% 
% function updateView(~, ~, h, clusPC, u, sel, axisChoice, sldr)
% [caz,cel] = view(h);
% cla(h)
% 
% for ii=1:length(sel)
%     iiCmap = getColour(ii);
%     ms = getMarker(ii);
%     if ~isempty(u(sel(ii)).waves)
%         for jj = 1:length(axisChoice)
%             choice(jj) = find(strcmp(axisChoice(ii).Value,axisChoice(ii).Items),1,'first');
%         end
%         if choice(3).Value ~= length(axisChoice(3).Items)
%             scatter3(h, clusPC{ii}(:,choice(1)),clusPC{ii}(:,choice(2)),clusPC{ii}(:,choice(3)),sldr.Value,...
%                 repmat(iiCmap,size(clusPC{ii},1),1),"Marker",ms);
%             if caz == 0 && cel == 90
%                 view(h,[-5 2 5]);
%             end
%         else
%             scatter(h, clusPC{ii}(:,choice(1)),clusPC{ii}(:,choice(2)),sldr.Value,...
%                 repmat(iiCmap,size(clusPC{ii},1),1),"Marker",ms);
%             view(h,2);
%         end
%     end
% end
% 
% xlabel(h,axisChoice(1).Value); ylabel(h,axisChoice(2).Value);
% if choice(3).Value ~= length(axisChoice(3).Items)
%     zlabel(h,axisChoice(3).Value);
% end
% 
% end

function clickedUnassigned(~,evt,app)
if app.interactingFlag(1) ~= 0
    return;
end
u = evt.IntersectionPoint;

X = get(app.pUnassignedPC,'XData');
Y = get(app.pUnassignedPC,'YData');
Z = get(app.pUnassignedPC,'ZData');
r = sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2+(u(1,3)-Z).^2);
[~ ,selectedPoint]=min(r);
updateUnassignedSelection(app, selectedPoint);

end

function ROIClick(~,~,app,sldr,axisChoice,allPC,selection)
if app.interactingFlag(1) ~= 0
    return;
end

for ii = 1:3
    labels(ii) = string(axisChoice(ii).Value);
end

selectedPoint = ROI3D(allPC,1,[0,0,0; getColour(1:length(selection))],...
    [".", getMarker(1:length(selection))],...
    sldr.Value*ones(size(allPC)),labels);

updateUnassignedSelection(app, selectedPoint);


end

