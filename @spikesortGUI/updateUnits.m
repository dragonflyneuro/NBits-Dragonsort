function [] = updateUnits(app, d, opt)

if ~opt
    for ii = 1:length(app.unitArray)
        [~, ~, ~, idx] = app.unitArray(ii).getAssignedSpikes(app.t, app.currentBatch);
        app.unitArray = app.unitArray.spikeRemover(ii,idx);
    end
end
[a,b,c]=app.unitArray.getOrphanSpikes(app.t,app.currentBatch,app.rawSpikeWaves);

for ii = 1:length(app.unitArray)
    app.unitArray(ii).refineSettings = d.scaleArray(ii);
    app.unitArray = app.unitArray.refinedSpikeAdder(ii,a(d.spikeAssignmentUnit == ii),...
        b(d.spikeAssignmentUnit == ii,:,:),c(d.spikeAssignmentUnit == ii));
end
app.unitArray = app.unitArray.unitSorter();
app.t.add2UnitThr(1) = d.add2UnitThr(1);
% 
% c = app.currentBatch;
% bl = app.t.batchLengths;
% spikeRange = sum(app.t.numSpikesInBatch(1:c-1))+1:sum(app.t.numSpikesInBatch(1:c));
% spikesInBatch = app.t.rawSpikeSample(spikeRange);
% if ~isrow(d.spikeAssignmentUnit)
%     newAssignments = d.spikeAssignmentUnit';
% else
%     newAssignments = d.spikeAssignmentUnit;
% end
% app.t.orphanBool(spikeRange) = ~logical(newAssignments);
% app.t.spikeClust(spikeRange) = newAssignments;
% for ii = app.s.clusters
%     unitSpikesInBatchBool = sum(bl(1:c-1)) < app.s.("unit_"+ii) & app.s.("unit_"+ii) <= sum(bl(1:c));
%     reassginedSpikesBool = newAssignments == str2double(ii);
%     app.s.("unit_"+ii)(unitSpikesInBatchBool) = [];
%     app.s.("waves_"+ii)(unitSpikesInBatchBool,:,:) = [];
%     
%     app.s.("unit_"+ii) = [app.s.("unit_"+ii) spikesInBatch(reassginedSpikesBool)];
%     app.s.("waves_"+ii) = [app.s.("waves_"+ii); app.rawSpikeWaves(reassginedSpikesBool,:,:)];
% end

app.redrawTracePlot2(app.figureHandles(1), app.figureHandles(2));
app.redrawUnitPlots2(app.figureHandles);

app.addHistory();
figure(app.UIBase);
end