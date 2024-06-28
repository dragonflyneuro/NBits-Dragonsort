function unassignedLine = plotUnassignedSpikes(app,h,ch)
unassignedLine = [];

r = getBatchRange(app);

[spikes, ~] = app.unitArray.getUnassignedSpikes(app.t.rawSpikeSample,r);

if isempty(spikes)
    return;
end

spikes = spikes - r(1);

x(1,:) = spikes*app.msConvert;
y(1,:) = app.xi(ch,spikes);

unassignedLine = line(h, x, y,'Color', 'k', 'Marker', '.', 'LineStyle', 'none');

end
