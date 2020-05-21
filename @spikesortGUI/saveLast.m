function [] = saveLast(app)
app.lastStep.s = app.s;
app.lastStep.m = app.m;
app.lastStep.t = app.t;
app.lastStep.currentBatch = app.currentBatch;
app.lastStep.rawSpikeWaves = app.rawSpikeWaves;
app.lastStep.LI = app.LeftUnitDropDown.Items;
app.lastStep.RI = app.RightUnitDropDown.Items;
app.lastStep.LV = app.LeftUnitDropDown.Value;
app.lastStep.RV = app.RightUnitDropDown.Value;

app.lastStep.savePath = app.savePath;
app.lastStep.spikesshown = app.SpikeshownField.Value;
end