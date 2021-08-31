function assginedLine = plotAssignedSpikes(app,h,ch)
assginedLine = [];

r = getBatchRange(app);

d = 1;
for ii = 1:length(app.unitArray)
    unitSpikesInBatch = app.unitArray(ii).getAssignedSpikes(r);
    spikes = unitSpikesInBatch - r(1);
    
    if ~isempty(spikes)
        [ms, msSize] = getMarker(ii);
        
        % set up interactivity with assigned spikes to select
        % waveforms in left unit figure from trace
        assignedLine(d) = line(h, spikes*app.msConvert, app.xi(ch,spikes), ...
            'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize, 'Color', getColour(ii));
        d = d+1;
    end
end
end
