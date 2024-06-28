function [unitLines, traceLine, plottedWaves] = plotUnit(app, hTitle, hUnit, uIdx)

unitLines = [];
traceLine = [];

[~, plottedWaves] = getPlottableWaves(app, uIdx);

if ~isempty(plottedWaves)
    templateBatches = [-app.PastbatchesTField.Value, app.FuturebatchesTField.Value];  % batches to make templates from
    r = getBatchRange(app, app.currentBatch+templateBatches);
    [dev, ~, ~] = getDevMatrix(1, app.unitArray(uIdx), plottedWaves, r, app.SpikesusedEditField.Value, app.m.sRateHz, 0);
    app.unitArray(uIdx).meanDeviation = mean(dev);
else
    app.unitArray(uIdx).meanDeviation = 0;
end

hTitle.Value = getUnitTitle(app, uIdx);

if isempty(plottedWaves)
    return;
end

[unitLines,traceLine,~] = drawUnitLines(app, hUnit, uIdx, plottedWaves, ">");

end