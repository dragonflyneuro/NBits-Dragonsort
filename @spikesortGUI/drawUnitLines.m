function [unitLines,traceLine,unitSpikesInBatchIdx] = drawUnitLines(app, hUnit, uIdx, plottedWaves, markerStyle)

r = getBatchRange(app);
traceLine = [];
unitSpikesInBatchIdx = [];

if ~isempty(app.unitArray(uIdx).spikeTimes) % if there are spikes in the unit
        %   find spikes in current batch for trace selection
    [unitSpikesInBatch,~,unitSpikesInBatchIdx] = app.unitArray(uIdx).getAssignedSpikes(getBatchRange(app));
    inBatchSpikeTimes = unitSpikesInBatch - r(1);
    
    traceLine = line(app.traceAx, inBatchSpikeTimes*app.msConvert, app.xi(app.m.mainCh,inBatchSpikeTimes),...
        'LineStyle', 'none', 'Marker', markerStyle, 'Color', getColour(uIdx));
    app.traceAx.Children = app.traceAx.Children([2:(end-length(app.eventMarkerArr)), 1, (end-length(app.eventMarkerArr)+1):end]);
    if ~isempty(app.dataAllChAx) && ishandle(app.dataAllChAx)
        ax = app.dataAllChAx.Children.Children;
        for jj = 1:size(app.xi,1)
            line(ax(jj), -inBatchSpikeTimes*app.msConvert, app.xi(jj,inBatchSpikeTimes),...
                'LineStyle', 'none', 'Marker', markerStyle, 'Color', getColour(uIdx));
        end
    end
end

unitLines = line(hUnit, -app.m.spikeWidth:app.m.spikeWidth, plottedWaves(:,:,app.m.mainCh)');
formatWaveAxes(app,hUnit,[min(min(plottedWaves(:,:,app.m.mainCh))),max(max(plottedWaves(:,:,app.m.mainCh)))])

end