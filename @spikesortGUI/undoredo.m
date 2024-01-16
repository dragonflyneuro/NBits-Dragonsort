function [] = undoredo(app,dir)

maxHistory = 15;

if app.counter == 1 && dir == -1
    return;
end
if app.counter == maxHistory && dir == 1
    return;
end

app.counter = app.counter+dir;

app.unitArray = app.historyStack(app.counter).uA.copy();
app.m = app.historyStack(app.counter).m;
app.t = app.historyStack(app.counter).t;
app.currentBatch = app.historyStack(app.counter).currentBatch;
app.DetectThr1EditField.Value = app.t.detectThr(1);
app.DetectThr2EditField.Value = app.t.detectThr(2);
app.BatchsizeEditField.Value = app.t.batchSize;
app.LeftUnitDropDown.Items = app.historyStack(app.counter).LI;
app.RightUnitDropDown.Items = app.historyStack(app.counter).RI;
app.LeftUnitDropDown.Value = app.historyStack(app.counter).LV;
app.RightUnitDropDown.Value = app.historyStack(app.counter).RV;
app.MainchannelDropDown.Value = string(app.m.mainCh);
app.SpikewidthEditField.Value = app.m.spikeWidth;

app.savePath = app.historyStack(app.counter).savePath;
app.SpikeshownField.Value = app.historyStack(app.counter).spikesshown;

app.readFilter(app.currentBatch);
app.redrawTracePlot();
app.redrawUnitPlots();

end