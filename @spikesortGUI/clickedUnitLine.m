function clickedUnitLine(app, src, ~)

selectedSpike = cell2mat(get(app.leftUnitLines,'UserData')) == src.UserData;
updateAssignedSelection(app, selectedSpike)

end