function clickedUnitLine(app, src, ~)

selectedSpike = cell2mat(get(app.pL,'UserData')) == src.UserData;
updateAssignedSelection(app, selectedSpike)

end