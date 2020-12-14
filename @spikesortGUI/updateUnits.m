function [] = updateUnits(app, d, opt)
[num,newAssignments]=max(d.spikeAssignmentUnit,[],2);
newAssignments(num == 0) = 0;
if ~opt
    for ii = 1:length(app.unitArray)
        [~, ~, idx] = app.unitArray(ii).getAssignedSpikes(getBatchRange(app));
        app.unitArray = app.unitArray.spikeRemover(ii,idx, 1);
    end
end
[sTimes,~,batchIdx] = app.unitArray.getOrphanSpikes(app.t.rawSpikeSample,getBatchRange(app));
sWaves = app.rawSpikeWaves(batchIdx,:,:);
for ii = 1:length(app.unitArray)
    app.unitArray(ii).refineSettings = d.scaleArray(ii);
    app.unitArray = app.unitArray.refinedSpikeAdder(ii,sTimes(newAssignments == ii),...
        sWaves(newAssignments == ii,:,:));
end
app.unitArray = app.unitArray.unitSorter();

standardUpdate(app)
figure(app.UIBase);
end