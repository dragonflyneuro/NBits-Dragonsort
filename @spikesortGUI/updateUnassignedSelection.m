function [] = updateUnassignedSelection(app)
h = app.dataAx;

if ~isempty(app.pSelected) && ishandle(app.pSelected)
    app.pSelected.MarkerIndices = app.dataAx.UserData.selectedUnassigned;
else
    X = get(app.pUnassigned,'XData');
    Y = get(app.pUnassigned,'YData');
    app.pSelected = plot(h, X,Y, 'ro','MarkerIndices',app.dataAx.UserData.selectedUnassigned);
    h.Children = h.Children([2:(end-length(app.pEvent)), 1, (end-length(app.pEvent)+1):end]);
end

end