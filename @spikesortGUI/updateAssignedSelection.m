function [] = updateAssignedSelection(app, selection)
if app.interactingFlag(2) ~= 0
    return;
end

alreadySelectedBool = ismember(get(app.pL,'LineStyle'),':');
if ~islogical(selection)
    temp = false(size(alreadySelectedBool));
    temp(selection) = true;
    selection = temp;
end
[app.pL(selection & ~alreadySelectedBool).LineStyle] = deal(':');
[app.pL(selection & alreadySelectedBool).LineStyle] = deal('-');
if ~isempty(app.pLF) && ishandle(app.pLF)
    app.leftUnitAx.UserData.selectedIdx = selection & ~alreadySelectedBool;
end
end