function [] = updateUnassignedSelectionF(app, addIdx, removeIdx)
hF = app.dataFeatureAx;

X = get(app.pUnassignedF,'XData');
Y = get(app.pUnassignedF,'YData');
Z = get(app.pUnassignedF,'ZData');

if ~isempty(Z)
    for ii = 1:length(addIdx)
        app.pSelectedF(end+1) = scatter3(hF, X(addIdx(ii)),Y(addIdx(ii)),Z(addIdx(ii)),'ro');
    end
else
    for ii = 1:length(addIdx)
        app.pSelectedF(end+1) = scatter(hF, X(addIdx(ii)),Y(addIdx(ii)),'ro');
    end
end
if ~isempty(addIdx)
    hF.Children = hF.Children([ii+1:end, 1:ii]);
end

delete(app.pSelectedF(removeIdx))
app.pSelectedF(removeIdx) = [];

end