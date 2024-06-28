function [] = createAssignedSelectionF(app)
hF = app.dataFeatureAx;
UD = ismember(get(app.leftUnitLines,'LineStyle'),':');
app.selectedFeatureMarkers = [];

X = get(app.leftUnitFeatureMarkers,'XData');
Y = get(app.leftUnitFeatureMarkers,'YData');
Z = get(app.leftUnitFeatureMarkers,'ZData');

if ~isempty(Z)
    app.selectedFeatureMarkers = plot3(hF,X,Y,Z,'ro','MarkerIndices',UD,'MarkerSize',10);
else
    app.selectedFeatureMarkers = plot(hF,X,Y,'ro','MarkerIndices',UD,'MarkerSize',10);
end
hF.Children = hF.Children([2:end, 1]);

end