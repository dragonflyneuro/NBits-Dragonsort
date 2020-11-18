function [] = saveLast(app)

lS.uA = app.uA;
lS.m = app.m;
lS.t = app.t;
lS.currentBatch = app.currentBatch;
lS.rawSpikeWaves = app.rawSpikeWaves;
lS.LI = app.LeftUnitDropDown.Items;
lS.RI = app.RightUnitDropDown.Items;
lS.LV = app.LeftUnitDropDown.Value;
lS.RV = app.RightUnitDropDown.Value;

lS.savePath = app.savePath;
lS.spikesshown = app.SpikeshownField.Value;

app.historyStack = [lS, app.historyStack(app.counter:end)];
if length(app.historyStack) > 4
    app.historyStack = app.historyStack(1:4);
end
app.counter = 1;
end