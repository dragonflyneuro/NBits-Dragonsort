function [] = updateDataFeatureAx(app, axisChoice, sizeSldr, posData, sel)
h  = app.dataFeatureAx;
for ii = 1:length(axisChoice)
    choice(ii) = find(strcmp(axisChoice(ii).Value,axisChoice(ii).Items),1,'first');
end
if choice(3) ~= length(axisChoice(3).Items)
    zlabel(h,axisChoice(1).Value);
else
    choice(3) = [];
end

scatterH = updateView(h, posData, sel, choice, sizeSldr.Value);

sel = sel(cellfun(@(x) ~isempty(x),posData(2:end)));
if ~isempty(posData{1})
    legend(h,["Unassigned", "Unit " + sel],'AutoUpdate','off');
else
    legend(h,"Unit " + sel,'AutoUpdate','off');
end

if ~strcmpi(app.featureSelectMode,'unit')
    if ~isempty(scatterH(1)) && ishandle(scatterH(1))
        app.unassignedFeatureMarkers = scatterH(1);
        app.createUnassignedSelectionF();
        set(app.unassignedFeatureMarkers, 'ButtonDownFcn',{@app.clickedUnassigned,app.unassignedFeatureMarkers});
    end
else
    val = str2double(app.LeftUnitDropDown.Value);
    if ~isempty(scatterH(val+1)) && ishandle(scatterH(val+1))
        app.leftUnitFeatureMarkers = scatterH(val+1);
        app.createUnassignedSelectionF();
        set(app.leftUnitFeatureMarkers, 'ButtonDownFcn',{@app.clickedUnitLineF,app.unassignedFeatureMarkers});
    end
end

xlabel(h,axisChoice(1).Value);
ylabel(h,axisChoice(2).Value);
zlabel(h,axisChoice(3).Value);

end
