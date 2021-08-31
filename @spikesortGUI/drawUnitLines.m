function [unitLines,traceLine,unitSpikesInBatchIdx] = drawUnitLines(app, hUnit, unitNum, plottedWaves, markerStyle)

r = getBatchRange(app);
traceLine = [];
unitSpikesInBatchIdx = [];

if ~isempty(app.unitArray(unitNum).spikeTimes) % if there are spikes in the unit
        %   find spikes in current batch for trace selection
    [unitSpikesInBatch,~,unitSpikesInBatchIdx] = app.unitArray(unitNum).getAssignedSpikes(getBatchRange(app));
    inBatchSpikeTimes = unitSpikesInBatch - r(1);
    
    traceLine = line(app.dataAx, inBatchSpikeTimes*app.msConvert, app.xi(app.m.mainCh,inBatchSpikeTimes),...
        'LineStyle', 'none', 'Marker', markerStyle, 'Color', getColour(unitNum));
    app.dataAx.Children = app.dataAx.Children([2:(end-length(app.pEvent)), 1, (end-length(app.pEvent)+1):end]);
    if ~isempty(app.spT) && ishandle(app.spT)
        ax = app.spT.Children.Children;
        for jj = 1:size(app.xi,1)
            line(ax(jj), -inBatchSpikeTimes*app.msConvert, app.xi(jj,inBatchSpikeTimes),...
                'LineStyle', 'none', 'Marker', markerStyle, 'Color', getColour(unitNum));
        end
    end
end

unitLines = line(hUnit, -app.m.spikeWidth:app.m.spikeWidth, plottedWaves(:,:,app.m.mainCh)');

if ~isinf(app.yLimLowField.Value)
    yl(1) = app.yLimLowField.Value;
else
    yl(1) = min(min(plottedWaves(:,:,app.m.mainCh)))-50;
end
if ~isinf(app.yLimHighField.Value)
    yl(2) = app.yLimHighField.Value;
else
    yl(2) = max(max(plottedWaves(:,:,app.m.mainCh)))+50;
end

step = 50*ceil((yl(2) - yl(1))/500);
ticks = unique([0:-step:50*floor(yl(1)/50), 0:step:50*floor(yl(2)/50)]);
ylim(hUnit,yl);
yticks(hUnit,ticks);
set(hUnit, 'YGrid', 'on', 'XGrid', 'off')

end