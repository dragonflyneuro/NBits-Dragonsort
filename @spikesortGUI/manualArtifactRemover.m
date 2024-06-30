function [] = manualArtifactRemover(app, h)
app.StatusLabel.Value = "ARTIFACT REMOVER ON! TURN OFF FOR NORMAL OPERATION."+...
    " Click on 2 points in the trace to denote region of spike elimination. Click on a region to remove it.";
app.switchButtons('menuOff');
app.switchButtons('opsOff');
drawnow

if ~isempty(app.assignedSpikeMarkers)
    for ii = 1:length(app.assignedSpikeMarkers)
        if ishandle(app.assignedSpikeMarkers(ii))
            set(app.assignedSpikeMarkers(ii), 'ButtonDownFcn',[]);
        end
    end
end
for ii = 1:length(app.eventMarkerArr)
    delete(app.eventMarkerArr(ii));
end

set(h,'ButtonDownFcn',{@selectTimeblock,app,h});
set(app.dataLine, 'ButtonDownFcn',{@selectTimeblock,app,h});
if ~isempty(app.unassignedSpikeMarkers)
    set(app.unassignedSpikeMarkers, 'ButtonDownFcn',[]);
end


if ~isempty(app.t.noSpikeRange)
    offset = getBatchRange(app); % used for converting samples from beginning of file to beginning of batch
    regionInBatch = offset(1) < app.t.noSpikeRange(1,:) & app.t.noSpikeRange(1,:) <= offset(2);
    regionInBatch = regionInBatch | (offset(1) < app.t.noSpikeRange(2,:) & app.t.noSpikeRange(2,:) <= offset(2));
    regionInBatch = find(regionInBatch);
    
    yl = ylim(h);
    for ii = 1:length(regionInBatch)
        regionCoord = (app.t.noSpikeRange(:,regionInBatch(ii))-offset(1))*app.msConvert;
        x = [regionCoord(1), regionCoord(1), regionCoord(2), regionCoord(2)];
        y = [yl(1), yl(2), yl(2), yl(1)];
        pgon = polyshape(x,y);
        app.artifactMarkerArr(ii) = plot(h, pgon, 'FaceColor','r','FaceAlpha',0.2,'LineStyle','none');
        set(app.artifactMarkerArr(ii),'ButtonDownFcn',{@selectTimeblock,app,h});
    end
end
end

%% callback
function selectTimeblock(~,evt,app,h)
if app.leftUnitAx.UserData.interactionType  ~= 'n'
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;

offset = getBatchRange(app); % used for converting samples from beginning of file to beginning of batch

% if time range not defined yet
if ~ishandle(app.selectionBox)
    q = 0;
    % if first click is within an already defined region,
    % delete said region
    if ~isempty(app.t.noSpikeRange)
        v = u/app.msConvert;
        
        regionInBatch = offset(1) < app.t.noSpikeRange(1,:) & app.t.noSpikeRange(1,:) <= offset(2);
        regionInBatch = regionInBatch | (offset(1) < app.t.noSpikeRange(2,:) & app.t.noSpikeRange(2,:) <= offset(2));
        regionInBatch = find(regionInBatch);
        
        for jj = 1:length(regionInBatch)
            q = 0;
            inRegion = app.t.noSpikeRange(1,regionInBatch(jj))-offset(1) <= v(1,1) &...
                v(1,1) <= app.t.noSpikeRange(2,regionInBatch(jj))-offset(1);
            if inRegion
                delete(app.artifactMarkerArr(jj));
                app.artifactMarkerArr(jj) = [];
                app.t.noSpikeRange(:,regionInBatch(jj)) = [];
                q = 1;
                break;
            end
        end
    end
    
    % get first line and draw
    if q == 0
        app.selectionBox = plot(h, [u(1,1),u(1,1)], ylim(h), 'r');
    end
else
    % get second line and draw
    x = [app.selectionBox.XData(1), app.selectionBox.XData(1), u(1,1), u(1,1)];
    y = [-200, 200, 200, -200];
    pgon = polyshape(x,y);
    
    app.t.noSpikeRange(:,end+1) = sort([app.selectionBox.XData(1); u(1,1)])/app.msConvert + offset(1);
    delete(app.selectionBox);
    
    app.selectionBox = plot(h, pgon, 'FaceColor','r','FaceAlpha',0.2,'LineStyle','none');
    app.artifactMarkerArr(end+1) = app.selectionBox;
    set(app.artifactMarkerArr(end),'ButtonDownFcn',{@selectTimeblock,app});
    app.selectionBox = gobjects(1);
end
end