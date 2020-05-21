function [] = updateUnits(app, d)
app.saveLast();

app.t.refineSettings{2} = d.scaleArray;
app.t.add2UnitThr(1) = d.add2UnitThr(1);

c = app.currentBatch;
bl = app.t.batchLengths;
spikeRange = sum(app.t.numSpikesInBatch(1:c-1))+1:sum(app.t.numSpikesInBatch(1:c));
spikesInBatch = app.t.rawSpikeSample(spikeRange);
if ~isrow(d.spikeAssignmentUnit)
    newAssignments = d.spikeAssignmentUnit';
else
    newAssignments = d.spikeAssignmentUnit;
end
app.t.orphanBool(spikeRange) = ~logical(newAssignments);
app.t.spikeClust(spikeRange) = newAssignments;
for ii = app.s.clusters
    unitSpikesInBatchBool = sum(bl(1:c-1)) < app.s.("unit_"+ii) & app.s.("unit_"+ii) <= sum(bl(1:c));
    reassginedSpikesBool = newAssignments == str2double(ii);
    app.s.("unit_"+ii)(unitSpikesInBatchBool) = [];
    app.s.("waves_"+ii)(unitSpikesInBatchBool,:,:) = [];
    
    app.s.("unit_"+ii) = [app.s.("unit_"+ii) spikesInBatch(reassginedSpikesBool)];
    app.s.("waves_"+ii) = [app.s.("waves_"+ii); app.rawSpikeWaves(reassginedSpikesBool,:,:)];
end
app.unitSorter();
app.redrawTracePlot();
app.redrawUnitPlots();

figure(app.UIBase);
end