function [] = showPCAOverview(u, selection)

[waves, ~, PC] = getPCs(u, selection);
for ii=1:length(waves)
    clusPC{ii}=waves{ii}*PC(:,1:6);
end

drawnow

%PCA view-interactive
f = uifigure('Name','PCA Overview');
set(f, 'Position',  [1100, 200, 800, 700]);
axPC = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(axPC,[-5 2 5]);

for ii=1:length(selection)
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    if ~isempty(u(selection(ii)).waves)
        scatter3(axPC,clusPC{ii}(:,1),clusPC{ii}(:,2),clusPC{ii}(:,3),20,...
            repmat(iiCmap,size(clusPC{ii},1),1),"Marker",ms); % 3D PCA plot
    end
end

labels = "PC"+string(1:6);
xlabel(axPC,labels(1)); ylabel(axPC,labels(2)); zlabel(axPC,labels(3));
title(axPC,'Units found - PCs view');
legend(axPC,"Unit " + selection);

markerSizeSldr = uislider(f,'Position',[50 80 700 3], 'Value',20, 'Limits',[1 200],...
    'ValueChangingFcn',{@sliderMoving, axPC});
axisChoice(1) = uidropdown(f,'Items', labels, 'Value',labels(1),...
    'Position',[100 20 200 22]);
axisChoice(2) = uidropdown(f,'Items', labels, 'Value',labels(2),...
    'Position',[300 20 200 22]);
axisChoice(3) = uidropdown(f,'Items', [" ", labels], 'Value',labels(3),...
    'Position',[500 20 200 22]);
for ii = 1:3
    set(axisChoice(ii),'ValueChangedFcn', {@updateView, clusPC, u, selection, axPC, axisChoice, markerSizeSldr});
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