function assignedLine = plotAssignedSpikes(app,h,ch)
assignedLine = [];

r = getBatchRange(app);

c = 1;
for ii = 1:length(app.unitArray)
    [unitSpikesInBatch, ~, inUnitIdx] = app.unitArray(ii).getAssignedSpikes(r);
    spikes = unitSpikesInBatch - r(1);
    
    if ~isempty(spikes)
        [ms, msSize] = getMarker(ii);
        
        % set up interactivity with assigned spikes to select
        % waveforms in left unit figure from trace
        assignedLine(c) = line(h, spikes*app.msConvert, app.xi(ch,spikes), ...
            'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize, 'Color', getColour(ii));
        tempStruct.uIdx = ii;
        tempStruct.spikeIdx = inUnitIdx;
        set(assignedLine(c),'UserData',tempStruct);
        c = c+1;
    end
end
end
