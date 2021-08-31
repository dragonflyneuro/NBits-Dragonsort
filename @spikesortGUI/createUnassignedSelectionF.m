function [] = createUnassignedSelectionF(app)
hF = app.dataFeatureAx;
UD = app.dataAx.UserData.selectedUnassigned;
app.pSelectedF = [];

X = get(app.pUnassignedF,'XData');
Y = get(app.pUnassignedF,'YData');
Z = get(app.pUnassignedF,'ZData');

if ~isempty(Z)
    app.pSelectedF = plot3(hF,X,Y,Z,'ro','MarkerIndices',UD,'MarkerSize',10);
else
    app.pSelectedF = plot(hF,X,Y,'ro','MarkerIndices',UD,'MarkerSize',10);
end
hF.Children = hF.Children([2:end, 1]);

end