function clickedUnassigned(app,~,evt,h)
if app.leftUnitAx.UserData.interactionType ~= 'n'
    return;
end
u = evt.IntersectionPoint;

X = get(h,'XData');
Y = get(h,'YData');
Z = get(h,'ZData');
if ~isempty(Z)
    r = sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2+(u(1,3)-Z).^2);
else
    r = sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
end
[~ ,selectedPoint] = min(r);
[~, removeIdx, IC] = intersect(app.traceAx.UserData.selectedUnassigned,selectedPoint);
addIdx = selectedPoint;
addIdx(IC) = [];

updateUnassignedUD(app, addIdx, removeIdx);
updateUnassignedSelection(app);
if ~isempty(app.dataFeatureAx) && ishandle(app.dataFeatureAx)
    updateUnassignedSelectionF(app);
end

end