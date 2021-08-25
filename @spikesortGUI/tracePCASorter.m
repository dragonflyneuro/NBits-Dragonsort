function f = tracePCASorter(app, u)
selection = 1:length(u);

[waves, PC] = getPCs(u, selection);
[~,~,orphansInBatch] = u.getOrphanSpikes(app.t.rawSpikeSample,getBatchRange(app));
orphanWaves = app.rawSpikeWaves(orphansInBatch,:);

for ii=1:length(waves)
    spikePC{ii}=waves{ii}*PC(:,1:6);
end

orphanPC = orphanWaves*PC(:,1:6);

%PCA view-interactive
f = uifigure('Name','PCA Overview');
set(f, 'Position',  [1100, 200, 800, 700]);
axPC = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(axPC,[-5 2 5]);

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

uibutton(f,'Position',[300 0 200 22], 'Name','ROI Select',...
    'ButtonDownFcn',{@ROIClick, app, [{orphanPC},spikePC]});
markerSizeSldr = uislider(f,'Position',[50 80 700 3], 'Value',20, 'Limits',[1 200],...
    'ValueChangingFcn',{@sliderMoving, axPC});
axisChoice(1) = uidropdown(f,'Items', labels, 'Value',labels(1),...
    'Position',[100 20 200 22]);
axisChoice(2) = uidropdown(f,'Items', labels, 'Value',labels(2),...
    'Position',[300 20 200 22]);
axisChoice(3) = uidropdown(f,'Items', [" ", labels], 'Value',labels(3),...
    'Position',[500 20 200 22]);
for ii = 1:3
    set(axisChoice(ii),'ValueChangedFcn', {@updateView, spikePC, u, selection, axPC, axisChoice, markerSizeSldr});
end


end

%% callbacks
function sliderMoving(~, e, h)
for ii = 1:length(h.Children)
    h.Children(ii).SizeData = e.Value;
end
end

function updateView(~, ~, clusPC, u, sel, h, axisChoice, sldr)
[caz,cel] = view(h);
cla(h)

for ii=1:length(sel)
    iiCmap = getColour(ii);
    ms = getMarker(ii);
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

xlabel(h,axisChoice(1).Value); ylabel(h,axisChoice(2).Value);
if axisChoice(3).Value ~= ' '
    zlabel(h,axisChoice(3).Value);
end

end

function clickedUnassigned(~,evt,app,h)
if app.interactingFlag(1) ~= 0
    return;
end
u = evt.IntersectionPoint;

X = get(app.pUnassignedPC,'XData');
Y = get(app.pUnassignedPC,'YData');
Z = get(app.pUnassignedPC,'ZData');
r = sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2+(u(1,3)-Z).^2);
[~ ,selectedPoint]=min(r);

alreadySelectedBool = ismember(h.UserData,selectedPoint);
if ~any(alreadySelectedBool)
    h.UserData = [h.UserData, selectedPoint];
    app.pSelectedPC(end+1) = plot3(h, X(selectedPoint),Y(selectedPoint),Z(selectedPoint),'ro');
    h.Children = h.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
else
    delete(app.pSelected(alreadySelectedBool))
    app.pSelectedPC(alreadySelectedBool) = [];
    h.UserData(alreadySelectedBool) = [];
end
end

function ROIClick(~,~,app,allPC)
h = app.Trace;
if app.interactingFlag(1) ~= 0
    return;
end

selectedPoint = ROI3D(allPC,1,[0,0,0; getColour(1:length(selection))],...
    [".", getMarker(1:length(selection))],...
    markerSizeSldr.Value*ones(size(allPC)));

for qq = 1:length(selectedPoint)
    alreadySelectedBool = ismember(h.UserData,selectedPoint(qq));
    if ~any(alreadySelectedBool)
        h.UserData = [h.UserData, selectedPoint(qq)];
        app.pSelectedPC(end+1) = plot(h, X(selectedPoint(qq)),Y(selectedPoint(qq)),'ro');
        app.pSelected(end+1) = plot(h, X(selectedPoint(qq)),Y(selectedPoint(qq)),'ro');
        h.Children = h.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
    else
        delete(app.pSelected(alreadySelectedBool))
        app.pSelectedPC(alreadySelectedBool) = [];
        h.UserData(alreadySelectedBool) = [];
        
        delete(app.pSelected(alreadySelectedBool))
        app.pSelected(alreadySelectedBool) = [];
    end
end

end

