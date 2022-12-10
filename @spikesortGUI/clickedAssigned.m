function clickedAssigned(app,src,evt)
% continue only if selected spike is of the left unit
if ~strcmp(app.LeftUnitDropDown.Value, string(src.UserData.unitNum))
    return;
end
if app.interactingFlag(1) ~= 0
    return;
end

u = evt.IntersectionPoint;
X = get(src,'XData');
Y = get(src,'YData');
r=sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint]=min(r);

% find index of selected point in unit spike time array
selection = cell2mat(get(app.pL,'UserData')) == src.UserData.spikeIdx(selectedPoint);

if any(selection)
    updateAssignedSelection(app, selection)
end

end