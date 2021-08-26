function unassignedLine = plotUnassignedSpikes(app,h,ch,interactFlag)
if ~exist('interactFlag','var') || isempty(interactFlag)
    interactFlag = 1;
end
unassignedLine = [];

c = app.currentBatch;
bl = app.t.batchLengths;
r = getBatchRange(app);

[spikes, ~] = app.unitArray.getOrphanSpikes(app.t.rawSpikeSample,r);

if isempty(spikes)
    return;
end

if c ~= 1
    spikes = spikes - sum(bl(1:c-1)) + app.m.spikeWidth;
end

x(1,:) = spikes*app.msConvert;
y(1,:) = app.xi(ch,spikes);

unassignedLine = line(h, x, y,'Color', 'k', 'Marker', '.', 'LineStyle', 'none');
if interactFlag
    set(unassignedLine, 'ButtonDownFcn',{@clickedUnassigned,app});
end

end

%% Callbacks
% allow selection of orphans in Trace
function clickedUnassigned(~,evt,app)
if app.interactingFlag(1) ~= 0
    return;
end
u = evt.IntersectionPoint;

X = get(app.pUnassigned,'XData');
Y = get(app.pUnassigned,'YData');
r = sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint] = min(r);
updateUnassignedSelection(app, selectedPoint);
end