function [unitLines, traceLine, plottedWaves] = plotUnit(app, hTitle, hUnit, unitNum)

unitLines = [];
traceLine = [];

hTitle.Value = getUnitTitle(app, unitNum);
[~, plottedWaves] = getPlottableWaves(app, unitNum);
if isempty(plottedWaves)
    return;
end

[unitLines,traceLine,~] = drawUnitLines(app, hUnit, unitNum, plottedWaves, ">");

end