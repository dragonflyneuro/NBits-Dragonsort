function [] = updateUnassignedSelection(app)
h = app.traceAx;

if ~isempty(app.selectedSpikeMarkers) && ishandle(app.selectedSpikeMarkers)
    app.selectedSpikeMarkers.MarkerIndices = app.traceAx.UserData.selectedUnassigned;
else
    X = get(app.unassignedSpikeMarkers,'XData');
    Y = get(app.unassignedSpikeMarkers,'YData');
    app.selectedSpikeMarkers = plot(h, X,Y, 'ro','MarkerIndices',app.traceAx.UserData.selectedUnassigned);
    h.Children = h.Children([2:(end-length(app.eventMarkerArr)), 1, (end-length(app.eventMarkerArr)+1):end]);
end

end