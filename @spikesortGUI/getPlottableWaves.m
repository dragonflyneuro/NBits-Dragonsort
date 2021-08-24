function [wavesIdx,validWaves] = getPlottableWaves(app, unitNum)

wavesIdx = [];
validWaves = [];

c = app.currentBatch;
bl = app.t.batchLengths;

if ~isempty(app.unitArray(unitNum).spikeTimes) % if there are spikes in the unit
    %    find spikes in viewing batches
    plotBatch = c + [-round(app.PastbatchesField.Value), min([round(app.FuturebatchesField.Value), length(bl)-c])];
    [~,~,unitSpikesInPlotIdx] = app.unitArray(unitNum).getAssignedSpikes(getBatchRange(app,plotBatch));
    validWaves = app.unitArray(unitNum).waves(unitSpikesInPlotIdx,:,:);
    wavesIdx = unitSpikesInPlotIdx;
    
elseif ~isempty(app.unitArray(unitNum).loadedTemplateWaves)
    validWaves = app.unitArray(unitNum).loadedTemplateWaves;
    
else
    return;
end

%      If the unit size is over the number to be plotted
if size(validWaves,1) > round(app.SpikeshownField.Value)
    validWaves = validWaves(end-round(app.SpikeshownField.Value)+1:end,:,:);
    if ~isempty(wavesIdx)
        wavesIdx = unitSpikesInPlotIdx(end-round(app.SpikeshownField.Value)+1:end);
    end
end

end