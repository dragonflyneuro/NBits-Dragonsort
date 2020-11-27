function [] = redrawTracePlot2(app,ht,hl)
c = app.currentBatch;
bl = app.t.batchLengths;
%   redraw batch time series in blue then overlay scatter for detected
%   spikes
app.StatusLabel.Value = "Redrawing data trace...";
cla(ht);
app.pSelected = gobjects(0);
app.pSelection = gobjects(1);
app.pEvent = [];


for ii = 1:4
%     cla(app.spT(ii));
end
ht.UserData = []; % Used for storing selected orphans

[orphanSpikes, ~, orphansIdx] = app.unitArray.getOrphanSpikes(app.t,app.currentBatch,app.rawSpikeWaves);
app.TTitle.Value = "Data trace (" + c + "/" + length(bl) + ")     Spikes assigned: " + ...
    string(app.t.numSpikesInBatch(c)-length(orphansIdx)) + "/" + app.t.numSpikesInBatch(c);

% main data line
app.pRaw = plotBig(ht, app.msConvert*(1:size(app.xi,2)), app.xi(app.m.mainCh,:),'Color','b');
set(app.pRaw, 'ButtonDownFcn',{@boxClick,app,ht});

xlim(ht, [0 app.msConvert*size(app.xi,2)]);
ylim(ht, 'auto');
yl = ylim(ht);
if ~isinf(app.yLimLowField.Value)
    yl(1) = app.yLimLowField.Value;
end
if ~isinf(app.yLimHighField.Value)
    yl(2) = app.yLimHighField.Value;
end
ylim(ht, yl);

if app.VieweventmarkersButton.Value == 1
    offset = sum(bl(1:c-1)); % used for converting samples from beginning of file to beginning of batch
    yl = ylim(ht);
    
    if min(size(app.t.importedEventBounds)) == 1
        regionInBatch = offset < app.t.importedEventBounds & app.t.importedEventBounds <= sum(bl(1:c));
        regionInBatch = find(regionInBatch);
        
        for jj = 1:length(regionInBatch)
            regionCoord = (app.t.importedEventBounds(regionInBatch(jj))-offset)*app.msConvert;
            xR = [regionCoord, regionCoord];
            yR = [yl(1), yl(2)];
            app.pEvent(jj) = plot(ht, xR, yR, 'Color', [0.5,0.5,0.5], 'LineStyle',':','LineWidth',1.5);
            set(app.pEvent(jj),'ButtonDownFcn',{@boxClick,app,ht});
        end
    else
        regionInBatch = offset < app.t.importedEventBounds(1,:) & app.t.importedEventBounds(1,:) <= sum(bl(1:c));
        regionInBatch = regionInBatch | (offset < app.t.importedEventBounds(2,:) & app.t.importedEventBounds(2,:) <= sum(bl(1:c)));
        regionInBatch = find(regionInBatch);
        
        for jj = 1:length(regionInBatch)
            regionCoord = (app.t.importedEventBounds(:,regionInBatch(jj))-offset)*app.msConvert;
            xR = [regionCoord(1), regionCoord(1), regionCoord(2), regionCoord(2)];
            yR = [yl(1), yl(2), yl(2), yl(1)];
            pgon = polyshape(xR,yR);
            app.pEvent(jj) = plot(ht, pgon, 'FaceColor','k', 'FaceAlpha',0.3,'LineStyle','none');
            set(app.pEvent(jj),'ButtonDownFcn',{@boxClick,app,ht});
        end
    end
end

ht.Children = flipud(ht.Children);

orphanSpikes = orphanSpikes - sum(bl(1:c-1));
% draw markers on data line for orphans
if ~isempty(orphanSpikes)
    x(1,:) = orphanSpikes*app.msConvert;
    y(1,:) = app.xi(app.m.mainCh,orphanSpikes);
    
    app.pUnassigned = line(ht, x, y,'Color', 'k', 'Marker', '.', 'LineStyle', 'none');
    set(app.pUnassigned, 'ButtonDownFcn',{@clickedUnassigned,app,ht});
    
    % markers on if multiple channels enabled
    if size(app.xi,1) > 0 && app.PlotallchButton.Value
        for ii = 1:size(app.xi,1)
            cla(app.spT(ii));
            plotBig(app.spT(ii), app.msConvert*(1:size(app.xi,2)), app.xi(ii,:),'Color','b');
            line(app.spT(ii), x, app.xi(ii,orphanSpikes),'Color', 'k', 'Marker', '.', 'LineStyle', 'none');
            xlim(app.spT(ii), [0 app.msConvert*size(app.xi,2)])
            ylim(app.spT(ii), yl);
        end
    end
end

% draw markers on data line for unit spikes
d = 1;
for ii = 1:length(app.unitArray)
    unitSpikesInBatch = app.unitArray(ii).getAssignedSpikes(app.t,app.currentBatch);
    tempUnit = unitSpikesInBatch - sum(bl(1:c-1));
    if ~isempty(tempUnit)
        [ms, msSize] = getMarker(size(app.cmap,1), ii);
        
        % set up interactivity with assigned spikes to select
        % waveforms in left unit figure from trace
        app.pAssigned(d) = line(ht, tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit), ...
            'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize, 'Color', app.cmap(rem(ii-1,25)+1,:));
        set(app.pAssigned(d), 'UserData', ii, 'ButtonDownFcn',{@clickedAssigned,app,hl});
        
        % markers on if multiple channels enabled
        if size(app.xi,1) > 0 && app.PlotallchButton.Value
            for jj = 1:size(app.xi,1)
                line(app.spT(jj), tempUnit*app.msConvert, app.xi(jj,tempUnit), ...
                    'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize, 'Color', app.cmap(rem(ii-1,25)+1,:));
            end
        end
        d = d+1;
    end
end

app.StatusLabel.Value = "Ready";

% set up interactivity for box selection of orphans in trace
set(ht,'ButtonDownFcn',{@boxClick,app,ht})

end

%% CALLBACKS

% allow box selection of orphans
function boxClick(~,evt,app,h)
if isempty(app.pUnassigned)
    return;
end
if app.interactingFlag(1)
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;
% if box corner not defined yet
if ~ishandle(app.pSelection)
    % get first box corner and draw crosshair
    app.pSelection = plot(h, u(1,1), u(1,2), 'r+', 'MarkerSize', 20);
else
    % get second box corner and draw box
    xBox = [app.pSelection.XData, u(1,1), u(1,1), app.pSelection.XData, app.pSelection.XData];
    yBox = [app.pSelection.YData, app.pSelection.YData, u(1,2), u(1,2), app.pSelection.YData];
    delete(app.pSelection);
    app.pSelection = plot(h, xBox, yBox, 'r');
    
    X = get(app.pUnassigned,'XData');
    Y = get(app.pUnassigned,'YData');
    
    % select orphans inside box
    selectedPoint = inpolygon(X,Y,xBox,yBox);
    selectedPoint = find(selectedPoint);
    drawnow
    
    % store selected orphans in UserData
    for qq = 1:length(selectedPoint)
        alreadySelectedBool = ismember(h.UserData,selectedPoint(qq));
        if ~any(alreadySelectedBool)
            h.UserData = [h.UserData, selectedPoint(qq)];
            app.pSelected(end+1) = plot(h, X(selectedPoint(qq)),Y(selectedPoint(qq)),'ro');
            h.Children = h.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
        else
            delete(app.pSelected(alreadySelectedBool))
            app.pSelected(alreadySelectedBool) = [];
            h.UserData(alreadySelectedBool) = [];
        end
    end
    delete(app.pSelection);
end
end


% allow selection of orphans in Trace
function clickedUnassigned(~,evt,app,h)
if app.interactingFlag(1)
    return;
end
u = evt.IntersectionPoint;

X = get(app.pUnassigned,'XData');
Y = get(app.pUnassigned,'YData');
r=sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint]=min(r);

alreadySelectedBool = ismember(h.UserData,selectedPoint);
if ~any(alreadySelectedBool)
    h.UserData = [h.UserData, selectedPoint];
    app.pSelected(end+1) = plot(h, X(selectedPoint),Y(selectedPoint),'ro');
    h.Children = h.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
else
    delete(app.pSelected(alreadySelectedBool))
    app.pSelected(alreadySelectedBool) = [];
    h.UserData(alreadySelectedBool) = [];
end
end


% allow selection of assigned spikes to select waveforms
function clickedAssigned(src,evt,app,hl)
% continue only if selected spike is of the left unit
if ~strcmp(app.LeftUnitDropDown.Value, string(src.UserData))
    return;
end
if app.interactingFlag(1)
    return;
end

u = evt.IntersectionPoint;
X = get(src,'XData');
Y = get(src,'YData');
r=sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint]=min(r);

% continue only if selected spike is plotted in left unit
[~, foundIdx] = ismember(hl.UserData{2}(selectedPoint),app.plottedWavesIdx);
if foundIdx < 1
    return;
end

if strcmp(app.pL(foundIdx).LineStyle, ':')
    app.pL(foundIdx).LineStyle = '-';
    temp = get(hl, 'UserData');
    hl.UserData{1} = temp{1}(temp{1} ~= app.plottedWavesIdx(foundIdx));
else
    app.pL(foundIdx).LineStyle = ':';
    temp = get(hl, 'UserData');
    hl.UserData{1} = [temp{1} app.plottedWavesIdx(foundIdx)];
end
end