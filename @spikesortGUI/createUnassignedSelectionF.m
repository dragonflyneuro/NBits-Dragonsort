function [] = createUnassignedSelectionF(app)
hF = app.dataFeatureAx;
UD = app.traceAx.UserData.selectedUnassigned;
app.selectedFeatureMarkers = [];

X = get(app.unassignedFeatureMarkers,'XData');
Y = get(app.unassignedFeatureMarkers,'YData');
Z = get(app.unassignedFeatureMarkers,'ZData');

if ~isempty(Z)
    app.selectedFeatureMarkers = plot3(hF,X,Y,Z,'ro','MarkerIndices',UD,'MarkerSize',10);
else
    app.selectedFeatureMarkers = plot(hF,X,Y,'ro','MarkerIndices',UD,'MarkerSize',10);
end
hF.Children = hF.Children([2:end, 1]);

end