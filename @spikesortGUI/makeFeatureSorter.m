function f = makeFeatureSorter(app, u)
%PCA view-interactive
f = uifigure('Name','Batch feature view');
set(f, 'Position',  [1100, 200, 800, 700]);
app.dataFeatureAx = uiaxes(f, 'Position', [50 100 700 550], 'NextPlot', 'Add');
view(app.dataFeatureAx,[-5 2 5]);

% ui elements
labels = "Feature"+string(1:6);
markerSizeSldr = uislider(f,'Position',[50 90 700 3], 'Value',20, 'Limits',[1 200],...
    'ValueChangingFcn',{@sliderMoving, app.dataFeatureAx});

for ii = 1:3
    axisChoice(ii) = uidropdown(f,'Items', labels, 'Value',labels(ii),...
        'Position',[100+200*(ii-1) 30 200 22],'UserData',ii);
end
axisChoice(3).Items = [axisChoice(3).Items," "];
end