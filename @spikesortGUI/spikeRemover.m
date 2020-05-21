function [] = spikeRemover(app, n, I)
app.saveLast();
app.StatusLabel.Value = "Removing spikes...";
drawnow
tW = app.s.("waves_"+n);
tU = app.s.("unit_"+n);

removeBool = ismember(app.t.rawSpikeSample, tU(I));
app.t.orphanBool(removeBool) = 1;
app.t.spikeClust(removeBool) = 0;

tU(I) = [];
tW(I,:,:) = [];
app.unitReassigner(n, tU, tW);
end