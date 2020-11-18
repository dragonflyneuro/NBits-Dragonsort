function [] = addHistory(app)

h.uA = app.unitArray.copy();
h.m = app.m;
h.t = app.t;
h.currentBatch = app.currentBatch;
h.rawSpikeWaves = app.rawSpikeWaves;
h.LI = app.LeftUnitDropDown.Items;
h.RI = app.RightUnitDropDown.Items;
h.LV = app.LeftUnitDropDown.Value;
h.RV = app.RightUnitDropDown.Value;

h.savePath = app.savePath;
h.spikesshown = app.SpikeshownField.Value;

if isempty(app.historyStack)
    app.historyStack = h;
else
    app.historyStack = [h, app.historyStack(app.counter:end)];
end

if length(app.historyStack) > 4
    app.historyStack = app.historyStack(1:4);
end
app.counter = 1;

end