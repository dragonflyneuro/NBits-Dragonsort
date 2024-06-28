function setMetricControlHandles(app,uiPos,uiObjArr)
app.Metrics.controlGridArr(uiPos).UserData = app.Metrics.dropDownArr(uiPos).Value;
app.Metrics.controlCell{uiPos} = [];
for ii = 1:length(uiObjArr)
    app.Metrics.controlCell{uiPos}(ii) = uiObjArr(ii);
end