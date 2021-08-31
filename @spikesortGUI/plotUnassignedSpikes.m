function unassignedLine = plotUnassignedSpikes(app,h,ch)
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

end
