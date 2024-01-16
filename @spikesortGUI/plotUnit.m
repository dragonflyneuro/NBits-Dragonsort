function [unitLines, traceLine, plottedWaves] = plotUnit(app, hTitle, hUnit, unitNum)

unitLines = [];
traceLine = [];

[~, plottedWaves] = getPlottableWaves(app, unitNum);

if ~isempty(plottedWaves)
    templateBatches = [-app.PastbatchesTField.Value, app.FuturebatchesTField.Value];  % batches to make templates from
    r = getBatchRange(app, app.currentBatch+templateBatches);
    [dev, ~, ~] = getDevMatrix(1, app.unitArray(unitNum), plottedWaves, r, app.SpikesusedEditField.Value, app.m.sRateHz, 0);
    app.unitArray(unitNum).meanDeviation = mean(dev);
else
    app.unitArray(unitNum).meanDeviation = 0;
end

hTitle.Value = getUnitTitle(app, unitNum);

if isempty(plottedWaves)
    return;
end

[unitLines,traceLine,~] = drawUnitLines(app, hUnit, unitNum, plottedWaves, ">");

end