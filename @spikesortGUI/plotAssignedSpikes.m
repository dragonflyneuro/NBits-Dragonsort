function assginedLine = plotAssignedSpikes(app,h,ch,hl)
if ~exist('hl','var') || isempty(hl)
    interactFlag = 0;
else
    interactFlag = 1;
end
assginedLine = [];


c = app.currentBatch;
bl = app.t.batchLengths;
r = getBatchRange(app);

d = 1;
for ii = 1:length(app.unitArray)
    unitSpikesInBatch = app.unitArray(ii).getAssignedSpikes(r);
    if c ~= 1
        spikes = unitSpikesInBatch - sum(bl(1:c-1)) + app.m.spikeWidth;
    else
        spikes = unitSpikesInBatch;
    end
    
    if ~isempty(spikes)
        [ms, msSize] = getMarker(size(app.cmap,1), ii);
        
        % set up interactivity with assigned spikes to select
        % waveforms in left unit figure from trace
        assignedLine(d) = line(h, spikes*app.msConvert, app.xi(ch,spikes), ...
            'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize, 'Color', app.cmap(rem(ii-1,25)+1,:));
        if interactFlag
            set(assignedLine(d), 'UserData', ii, 'ButtonDownFcn',{@clickedAssigned,app,hl});
        end
        d = d+1;
    end
end
end

%% Callbacks
% allow selection of orphans in Trace
% allow selection of assigned spikes to select waveforms
function clickedAssigned(src,evt,app,h)
% continue only if selected spike is of the left unit
if ~strcmp(app.LeftUnitDropDown.Value, string(src.UserData))
    return;
end
if app.interactingFlag(1) ~= 0
    return;
end

u = evt.IntersectionPoint;
X = get(src,'XData');
Y = get(src,'YData');
r=sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint]=min(r);

% continue only if selected spike is plotted in left unit
[~, foundIdx] = ismember(h.UserData{2}(selectedPoint),app.plottedWavesIdx);
if foundIdx < 1
    return;
end

if strcmp(app.pL(foundIdx).LineStyle, ':')
    app.pL(foundIdx).LineStyle = '-';
    temp = get(h, 'UserData');
    h.UserData{1} = temp{1}(temp{1} ~= app.plottedWavesIdx(foundIdx));
else
    app.pL(foundIdx).LineStyle = ':';
    temp = get(h, 'UserData');
    h.UserData{1} = [temp{1} app.plottedWavesIdx(foundIdx)];
end
end