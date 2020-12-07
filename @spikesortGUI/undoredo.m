function [] = undoredo(app,dir)

maxHistory = 6;

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

app.savePath = app.historyStack(app.counter).savePath;
app.SpikeshownField.Value = app.historyStack(app.counter).spikesshown;

%             offset = app.m.nChans*app.m.dbytes*sum(app.t.batchLengths(1:(app.currentBatch-1)));
app.readFilter2(app.currentBatch);
app.redrawTracePlot2(app.figureHandles(1),app.figureHandles(2));
app.redrawUnitPlots2(app.figureHandles);

end