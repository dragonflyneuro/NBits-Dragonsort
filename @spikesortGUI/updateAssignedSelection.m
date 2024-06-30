function [] = updateAssignedSelection(app, selection)
if app.traceAx.UserData.interactionType ~= 'n'
    return;
end

alreadySelectedBool = ismember(get(app.leftUnitLines,'LineStyle'),':');
if ~islogical(selection)
    temp = false(size(alreadySelectedBool));
    temp(selection) = true;
    selection = temp;
end
[app.leftUnitLines(selection & ~alreadySelectedBool).LineStyle] = deal(':');
[app.leftUnitLines(selection & alreadySelectedBool).LineStyle] = deal('-');
app.leftUnitAx.UserData.selectedIdx = xor(selection, alreadySelectedBool);
if ~isempty(app.leftUnitFeatureMarkers) && ishandle(app.leftUnitFeatureMarkers)
    app.leftUnitAx.UserData.selectedIdx = xor(selection, alreadySelectedBool);
end
end