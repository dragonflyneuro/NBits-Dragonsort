function [] = updateUnassignedUD(app, addIdx, removeIdx)
if size(addIdx,1) ~= 1
    addIdx = addIdx';
end
h = app.traceAx;
h.UserData.selectedUnassigned = [h.UserData.selectedUnassigned, addIdx];
h.UserData.selectedUnassigned(removeIdx) = [];

end