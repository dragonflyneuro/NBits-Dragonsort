function [] = createAssignedSelectionF(app)
hF = app.dataFeatureAx;
UD = ismember(get(app.pL,'LineStyle'),':');
app.pSelectedF = [];

X = get(app.pLF,'XData');
Y = get(app.pLF,'YData');
Z = get(app.pLF,'ZData');

if ~isempty(Z)
    app.pSelectedF = plot3(hF,X,Y,Z,'ro','MarkerIndices',UD,'MarkerSize',10);
else
    app.pSelectedF = plot(hF,X,Y,'ro','MarkerIndices',UD,'MarkerSize',10);
end
hF.Children = hF.Children([2:end, 1]);

end