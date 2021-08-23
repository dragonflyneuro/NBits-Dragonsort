function [] = showLDAOverview(app, u, selection)

if length(selection) < 2
    return;
end

drawnow

[~, clusW, ~] = getLDA(u, selection);

%LDA view-interactive
f = uifigure;
set(f, 'Position',  [1100, 200, 800, 700]);
axW = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(axW,[-5 2 5]);

for ii=1:length(selection)
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    ms = getMarker(size(app.cmap,1), ii);
    if ~isempty(u(selection(ii)).waves)
        scatter3(axW,clusW{ii}(:,1),clusW{ii}(:,2),clusW{ii}(:,3),20,...
            repmat(iiCmap,size(clusW{ii},1),1),"Marker",ms); % 3D WA plot
    end
end
labels = "W"+string(1:3); %length(selection);
xlabel(axW,labels(1)); ylabel(axW,labels(2)); zlabel(axW,labels(3));
title(axW,'Units found - LDA view');
legend(axW,"Unit " + selection);

markerSizeSldr = uislider(f,'Position',[50 80 700 3], 'Value',20, 'Limits',[1 200],...
    'ValueChangingFcn',{@sliderMoving, axW});
axisChoice(1) = uidropdown(f,'Items', labels, 'Value',labels(1),...
    'Position',[100 20 200 22]);
axisChoice(2) = uidropdown(f,'Items', labels, 'Value',labels(2),...
    'Position',[300 20 200 22]);
axisChoice(3) = uidropdown(f,'Items', [" ", labels], 'Value',labels(3),...
    'Position',[500 20 200 22]);
for ii = 1:3
    set(axisChoice(ii),'ValueChangedFcn', {@updateView, app, clusW, u, selection, axW, axisChoice, markerSizeSldr});
end

end

%% callbacks
function sliderMoving(~, e, h)
for ii = 1:length(h.Children)
    h.Children(ii).SizeData = e.Value;
end
end

function updateView(~, ~, app, clusW, u, sel, h, axisChoice, sldr)
[caz,cel] = view(h);
cla(h)

for ii=1:length(sel)
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    ms = getMarker(size(app.cmap,1), ii);
    if ~isempty(u(sel(ii)).waves)
        if axisChoice(3).Value ~= ' '
            for jj = 1:length(axisChoice)
                choice(jj) = sscanf(axisChoice(jj).Value,'W%d');
            end
            scatter3(h, clusW{ii}(:,choice(1)),clusW{ii}(:,choice(2)),clusW{ii}(:,choice(3)),sldr.Value,...
                repmat(iiCmap,size(clusW{ii},1),1),"Marker",ms);
            if caz == 0 && cel == 90
                view(h,[-5 2 5]);
            end
        else
            for jj = 1:2
                choice(jj) = sscanf(axisChoice(jj).Value,'W%d');
            end
            scatter(h, clusW{ii}(:,choice(1)),clusW{ii}(:,choice(2)),sldr.Value,...
                repmat(iiCmap,size(clusW{ii},1),1),"Marker",ms);
            view(h,2);
        end
    end
end

xlabel(h,axisChoice(1).Value); ylabel(h,axisChoice(2).Value);
if axisChoice(3).Value ~= ' '
    zlabel(h,axisChoice(3).Value);
end

end