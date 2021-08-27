function [] = updateUnassignedSelection(app, addIdx, removeIdx)
h = app.dataAx;

X = get(app.pUnassigned,'XData');
Y = get(app.pUnassigned,'YData');

for ii = 1:length(addIdx)
    app.pSelected(end+1) = plot(h, X(addIdx(ii)),Y(addIdx(ii)),'ro');
end
if ~isempty(addIdx)
    h.Children = h.Children([ii+1:end-length(app.pEvent), 1:ii, end-(length(app.pEvent)+1):end]);
end

delete(app.pSelected(removeIdx))
app.pSelected(removeIdx) = [];

end