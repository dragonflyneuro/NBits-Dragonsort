function [] = redrawTracePlot(app)
c = app.currentBatch;
bl = app.t.batchLengths;
%   redraw batch time series in blue then overlay scatter for detected
%   spikes
app.StatusLabel.Value = "Redrawing data trace...";
cla(app.Trace);
app.pSelected = gobjects(0);
app.pSelection = gobjects(1);
app.pStim = [];


for ii = 1:4
    cla(app.spT(ii));
end
app.Trace.UserData = []; % Used for storing selected orphans

spikesInBatch = sum(app.t.numSpikesInBatch(1:c-1))+1:sum(app.t.numSpikesInBatch(1:c)); % indices along orphanSpikes, spikeClust, rawSpikeSample for spikes within batch
orphansInBatchBool = app.t.orphanBool(spikesInBatch);
title(app.Trace,"Data trace (" + c + "/" + length(bl) + ")     Spikes assigned: " + ...
    nnz(~orphansInBatchBool) + "/" + app.t.numSpikesInBatch(c));

% main data line
app.pRaw = line(app.Trace, app.msConvert*(1:size(app.xi,2)), app.xi(app.m.mainCh,:),'Color','b');
set(app.pRaw, 'ButtonDownFcn',{@clickedTrace,app});

xlim(app.Trace, [0 app.msConvert*size(app.xi,2)]);
ylim(app.Trace, 'auto');
yl = ylim(app.Trace);
if ~isinf(app.yLimLowField.Value)
    yl(1) = app.yLimLowField.Value;
end
if ~isinf(app.yLimHighField.Value)
    yl(2) = app.yLimHighField.Value;
end
ylim(app.Trace, yl);

if app.ViewstimulusregionsButton.Value == 1
    offset = sum(bl(1:c-1)); % used for converting samples from beginning of file to beginning of batch
    yl = ylim(app.Trace);
    
    if min(size(app.t.importedStimulusBounds)) == 1
        regionInBatch = offset < app.t.importedStimulusBounds & app.t.importedStimulusBounds <= sum(bl(1:c));
        regionInBatch = find(regionInBatch);
        
        for jj = 1:length(regionInBatch)
            regionCoord = (app.t.importedStimulusBounds(regionInBatch(jj))-offset)*app.msConvert;
            xR = [regionCoord, regionCoord];
            yR = [yl(1), yl(2)];
            app.pStim(jj) = plot(app.Trace, xR, yR, 'Color', [0.5,0.5,0.5], 'LineStyle',':','LineWidth',1.5);
            set(app.pStim(jj),'ButtonDownFcn',{@clickedTrace,app});
        end
    else
        regionInBatch = offset < app.t.importedStimulusBounds(1,:) & app.t.importedStimulusBounds(1,:) <= sum(bl(1:c));
        regionInBatch = regionInBatch | (offset < app.t.importedStimulusBounds(2,:) & app.t.importedStimulusBounds(2,:) <= sum(bl(1:c)));
        regionInBatch = find(regionInBatch);
        
        for jj = 1:length(regionInBatch)
            regionCoord = (app.t.importedStimulusBounds(:,regionInBatch(jj))-offset)*app.msConvert;
            xR = [regionCoord(1), regionCoord(1), regionCoord(2), regionCoord(2)];
            yR = [yl(1), yl(2), yl(2), yl(1)];
            pgon = polyshape(xR,yR);
            app.pStim(jj) = plot(app.Trace, pgon, 'FaceColor','k', 'FaceAlpha',0.3,'LineStyle','none');
            set(app.pStim(jj),'ButtonDownFcn',{@clickedTrace,app});
        end
    end
end

app.Trace.Children = flipud(app.Trace.Children);

orphanSpikes = app.t.rawSpikeSample(spikesInBatch(orphansInBatchBool)) - sum(bl(1:c-1));
% draw markers on data line for orphans
if ~isempty(orphanSpikes)
    x(1,:) = orphanSpikes*app.msConvert;
    y(1,:) = app.xi(app.m.mainCh,orphanSpikes);
    
    app.pUnassigned = line(app.Trace, x, y,'Color', 'k', 'Marker', '.', 'LineStyle', 'none');
    set(app.pUnassigned, 'ButtonDownFcn',{@clickedUnassigned,app});
    
    % markers on if multiple channels enabled
    if size(app.xi,1) > 0 && app.PlotallchButton.Value
        for ii = 1:size(app.xi,1)
            cla(app.spT(ii));
            line(app.spT(ii), app.msConvert*(1:size(app.xi,2)), app.xi(ii,:),'Color','b');
            line(app.spT(ii), x, app.xi(ii,orphanSpikes),'Color', 'k', 'Marker', '.', 'LineStyle', 'none');
            xlim(app.spT(ii), [0 app.msConvert*size(app.xi,2)])
            ylim(app.spT(ii), yl);
        end
    end
end

% draw markers on data line for unit spikes
d = 1;
for ii = app.s.clusters
    unitSpikesInBatchBool = sum(bl(1:c-1)) < app.s.("unit_"+ii) & app.s.("unit_"+ii) <= sum(bl(1:c));
    tempUnit = app.s.("unit_"+ii)(unitSpikesInBatchBool) - sum(bl(1:c-1));
    if ~isempty(tempUnit)
        nii = str2double(ii);
        ms = getMarker(size(app.cmap,1), nii);
        
        % set up interactivity with assigned spikes to select
        % waveforms in left unit figure from trace
        app.pAssigned(d) = line(app.Trace, tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit), ...
            'LineStyle', 'none', 'Marker', ms, 'Color', app.cmap(rem(nii-1,25)+1,:));
        set(app.pAssigned(d), 'UserData', ii, 'ButtonDownFcn',{@clickedAssigned,app});
        
        % markers on if multiple channels enabled
        if size(app.xi,1) > 0 && app.PlotallchButton.Value
            for jj = 1:size(app.xi,1)
                line(app.spT(jj), tempUnit*app.msConvert, app.xi(jj,tempUnit), ...
                    'LineStyle', 'none', 'Marker', ms, 'Color', app.cmap(rem(nii-1,25)+1,:));
            end
        end
        d = d+1;
    end
end

app.StatusLabel.Value = "Ready";
if isempty(app.lastStep)
    app.UndoredoMenu.Enable = 'off';
else
    app.UndoredoMenu.Enable = 'on';
end

% set up interactivity for box selection of orphans in trace
set(app.Trace,'ButtonDownFcn',{@clickedTrace,app})

end

%% CALLBACKS

% allow box selection of orphans
function clickedTrace(~,evt,app)
if isempty(app.pUnassigned)
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;
% if box corner not defined yet
if ~ishandle(app.pSelection)
    % get first box corner and draw crosshair
    app.pSelection = plot(app.Trace, u(1,1), u(1,2), 'r+', 'MarkerSize', 20);
else
    % get second box corner and draw box
    xBox = [app.pSelection.XData, u(1,1), u(1,1), app.pSelection.XData, app.pSelection.XData];
    yBox = [app.pSelection.YData, app.pSelection.YData, u(1,2), u(1,2), app.pSelection.YData];
    delete(app.pSelection);
    app.pSelection = plot(app.Trace, xBox, yBox, 'r');
    
    X = get(app.pUnassigned,'XData');
    Y = get(app.pUnassigned,'YData');
    
    % select orphans inside box
    selectedPoint = inpolygon(X,Y,xBox,yBox);
    selectedPoint = find(selectedPoint);
    drawnow
    
    % store selected orphans in UserData
    for qq = 1:length(selectedPoint)
        alreadySelectedBool = ismember(app.Trace.UserData,selectedPoint(qq));
        if ~any(alreadySelectedBool)
            app.Trace.UserData = [app.Trace.UserData, selectedPoint(qq)];
            app.pSelected(end+1) = plot(app.Trace, X(selectedPoint(qq)),Y(selectedPoint(qq)),'ro');
            app.Trace.Children = app.Trace.Children([2:end-(length(app.pStim)+1), 1, end-(length(app.pStim)):end]);
        else
            delete(app.pSelected(alreadySelectedBool))
            app.pSelected(alreadySelectedBool) = [];
            app.Trace.UserData(alreadySelectedBool) = [];
        end
    end
    delete(app.pSelection);
end
end


% allow selection of orphans in Trace
function clickedUnassigned(~,evt,app)
u = evt.IntersectionPoint;

X = get(app.pUnassigned,'XData');
Y = get(app.pUnassigned,'YData');
r=sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint]=min(r);

alreadySelectedBool = ismember(app.Trace.UserData,selectedPoint);
if ~any(alreadySelectedBool)
    app.Trace.UserData = [app.Trace.UserData, selectedPoint];
    app.pSelected(end+1) = plot(app.Trace, X(selectedPoint),Y(selectedPoint),'ro');
    app.Trace.Children = app.Trace.Children([2:end-(length(app.pStim)+1), 1, end-(length(app.pStim)):end]);
else
    delete(app.pSelected(alreadySelectedBool))
    app.pSelected(alreadySelectedBool) = [];
    app.Trace.UserData(alreadySelectedBool) = [];
end
end


% allow selection of assigned spikes to select waveforms
function clickedAssigned(src,evt,app)
% continue only if selected spike is of the left unit
if ~strcmp(app.LeftUnitDropDown.Value, src.UserData)
    return;
end
u = evt.IntersectionPoint;
X = get(src,'XData');
Y = get(src,'YData');
r=sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint]=min(r);

% continue only if selected spike is plotted in left unit
[~, foundIdx] = ismember(app.lUnitInBatchIdx(selectedPoint),app.plottedWavesIdx);
if foundIdx < 1
    return;
end

if strcmp(app.pL(foundIdx).LineStyle, ':')
    app.pL(foundIdx).LineStyle = '-';
    temp = get(app.LeftUnit, 'UserData');
    set(app.LeftUnit, 'UserData', temp(temp ~= app.plottedWavesIdx(foundIdx)));
else
    app.pL(foundIdx).LineStyle = ':';
    temp = get(app.LeftUnit, 'UserData');
    set(app.LeftUnit, 'UserData', [temp app.plottedWavesIdx(foundIdx)]);
end
end