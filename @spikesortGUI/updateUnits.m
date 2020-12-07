function [] = updateUnits(app, d, opt)

if ~opt
    for ii = 1:length(app.unitArray)
        [~, ~, idx] = app.unitArray(ii).getAssignedSpikes(getBatchRange(app));
        app.unitArray = app.unitArray.spikeRemover(ii,idx);
    end
end
[sTimes,~,batchIdx]=app.unitArray.getOrphanSpikes(app.t.rawSpikeSample,getBatchRange(app));
sWaves = app.rawSpikeWaves(batchIdx,:,:);
for ii = 1:length(app.unitArray)
    app.unitArray(ii).refineSettings = d.scaleArray(ii);
    app.unitArray = app.unitArray.refinedSpikeAdder(ii,sTimes(d.spikeAssignmentUnit == ii),...
        sWaves(d.spikeAssignmentUnit == ii,:,:));
end
app.unitArray = app.unitArray.unitSorter();
app.t.add2UnitThr(1) = d.thr;

standardUpdate(app)
figure(app.UIBase);
end