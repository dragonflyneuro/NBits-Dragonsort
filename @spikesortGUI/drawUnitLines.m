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

ylTemp = [app.yLimLowField.Value, app.yLimHighField.Value];
yl = [min(min(plottedWaves(:,:,app.m.mainCh)))-50, max(max(plottedWaves(:,:,app.m.mainCh)))+50];
yl(~isinf(ylTemp)) = ylTemp(~isinf(ylTemp));
step = 50*ceil((yl(2) - yl(1))/500);
ticks = unique([0:-step:50*floor(yl(1)/50), 0:step:50*floor(yl(2)/50)]);
ylim(hUnit,yl);
yticks(hUnit,ticks);
set(hUnit, 'YGrid', 'on', 'XGrid', 'off')

end