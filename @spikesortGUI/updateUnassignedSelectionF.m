function [] = updateUnassignedSelectionF(app)

app.pSelectedF.MarkerIndices = app.dataAx.UserData.selectedUnassigned;

end