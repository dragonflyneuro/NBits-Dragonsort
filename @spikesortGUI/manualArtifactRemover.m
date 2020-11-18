function [] = manualArtifactRemover(app, h)
app.StatusLabel.Value = "ARTIFACT REMOVER ON! TURN OFF FOR NORMAL OPERATION."+...
    " Click on 2 points in the trace to denote region of spike elimination. Click on a region to remove it.";
switchButtons(app,0);
switchButtons(app,2);
drawnow

if ~isempty(app.pAssigned)
    for ii = 1:length(app.pAssigned)
        if ishandle(app.pAssigned(ii))
            set(app.pAssigned(ii), 'ButtonDownFcn',[]);
        end
    end
end
for ii = 1:length(app.pEvent)
    delete(app.pEvent(ii));
end

set(h,'ButtonDownFcn',{@selectTimeblock,app,h});
set(app.pRaw, 'ButtonDownFcn',{@selectTimeblock,app,h});
if ~isempty(app.pUnassigned)
    set(app.pUnassigned, 'ButtonDownFcn',[]);
end


if ~isempty(app.t.noSpikeRange)
    bl = app.t.batchLengths;
    c = app.currentBatch;
    offset = sum(bl(1:c-1)); % used for converting samples from beginning of file to beginning of batch
    regionInBatch = offset < app.t.noSpikeRange(1,:) & app.t.noSpikeRange(1,:) <= sum(bl(1:c));
    regionInBatch = regionInBatch | (offset < app.t.noSpikeRange(2,:) & app.t.noSpikeRange(2,:) <= sum(bl(1:c)));
    regionInBatch = find(regionInBatch);
    
    yl = ylim(h);
    for ii = 1:length(regionInBatch)
        regionCoord = (app.t.noSpikeRange(:,regionInBatch(ii))-offset)*app.msConvert;
        x = [regionCoord(1), regionCoord(1), regionCoord(2), regionCoord(2)];
        y = [yl(1), yl(2), yl(2), yl(1)];
        pgon = polyshape(x,y);
        app.pNospike(ii) = plot(h, pgon, 'FaceColor','r','FaceAlpha',0.2,'LineStyle','none');
        set(app.pNospike(ii),'ButtonDownFcn',{@selectTimeblock,app,h});
    end
end
end

%% callback
function selectTimeblock(~,evt,app,h)
% get clicked coordinates
u = evt.IntersectionPoint;

bl = app.t.batchLengths;
c = app.currentBatch;
offset = sum(bl(1:c-1)); % used for converting samples from beginning of file to beginning of batch

% if time range not defined yet
if ~ishandle(app.pSelection)
    q = 0;
    % if first click is within an already defined region,
    % delete said region
    if ~isempty(app.t.noSpikeRange)
        v = u/app.msConvert;
        
        regionInBatch = offset < app.t.noSpikeRange(1,:) & app.t.noSpikeRange(1,:) <= sum(bl(1:c));
        regionInBatch = regionInBatch | (offset < app.t.noSpikeRange(2,:) & app.t.noSpikeRange(2,:) <= sum(bl(1:c)));
        regionInBatch = find(regionInBatch);
        
        for jj = 1:length(regionInBatch)
            q = 0;
            inRegion = app.t.noSpikeRange(1,regionInBatch(jj))-offset <= v(1,1) & v(1,1) <= app.t.noSpikeRange(2,regionInBatch(jj))-offset;
            if inRegion
                delete(app.pNospike(jj));
                app.pNospike(jj) = [];
                app.t.noSpikeRange(:,regionInBatch(jj)) = [];
                q = 1;
                break;
            end
        end
    end
    
    % get first line and draw
    if q == 0
        app.pSelection = plot(h, [u(1,1),u(1,1)], ylim(h), 'r');
    end
else
    % get second line and draw
    yl = ylim(h);
    x = [app.pSelection.XData(1), app.pSelection.XData(1), u(1,1), u(1,1)];
    y = [yl(1), yl(2), yl(2), yl(1)];
    pgon = polyshape(x,y);
    
    app.t.noSpikeRange(:,end+1) = sort([app.pSelection.XData(1); u(1,1)])/app.msConvert + offset;
    delete(app.pSelection);
    
    app.pSelection = plot(h, pgon, 'FaceColor','r','FaceAlpha',0.2,'LineStyle','none');
    app.pNospike(end+1) = app.pSelection;
    set(app.pNospike(end),'ButtonDownFcn',{@selectTimeblock,app});
    app.pSelection = gobjects(1);
end
end