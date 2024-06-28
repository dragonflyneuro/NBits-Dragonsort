function [] = updateUnassignedSelectionF(app)

app.selectedFeatureMarkers.MarkerIndices = app.traceAx.UserData.selectedUnassigned;

end