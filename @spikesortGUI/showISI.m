function [] = showISI(app, uiPos, whichSide)
if strcmp(whichSide, 'left')
    uIdx = str2double(app.LeftUnitDropDown.Value);
else
    uIdx = str2double(app.RightUnitDropDown.Value);
end
isSameMetric = strcmp(app.Metrics.controlGridArr(uiPos).UserData, ...
    app.Metrics.dropDownArr(uiPos).Value);

if isSameMetric
    ax = app.Metrics.panelArr(uiPos).Children;
    cla(ax);
else
    delete(app.Metrics.panelArr(uiPos).Children);
    delete(app.Metrics.controlGridArr(uiPos).Children);

    app.Metrics.gridArr(uiPos).RowHeight = {22,'1x',80};
    app.Metrics.controlGridArr(uiPos).RowHeight = {'1x',22};
    app.Metrics.controlGridArr(uiPos).ColumnWidth = {'1x','1x','1x'};
    ax = axes('Parent',app.Metrics.panelArr(uiPos));
    xlabel(ax,'ISI (ms)')
    ylabel(ax,'Frequency per bin')
    xlim(ax,[0 100]);
    app.Metrics.controlGridArr(uiPos).UserData = app.Metrics.dropDownArr(uiPos).Value;
end

bE = 0:0.25:100;
ISI = diff(app.unitArray(uIdx).spikeTimes*1e3/app.m.sRateHz);
currentXLim = xlim(ax);
histogram(ax,ISI,bE,'Linestyle','none');
xlim(ax,currentXLim);
ax.UserData = ISI;

%controls
if ~isSameMetric
    violationCountLabel = uilabel(app.Metrics.controlGridArr(uiPos));
    violationCountLabel.Layout.Row = 2;
    violationCountLabel.Layout.Column = 3;
    violationCountLabel.Text = "# violations: " + string(sum(ISI < 1));

    violationThrField = uieditfield(app.Metrics.controlGridArr(uiPos),...
        "numeric", 'Limits',[0 inf],'Value',1,  ...
        'ValueChangedFcn', {@updateViolations, ax, violationCountLabel});
    violationThrField.Layout.Column = 2;
    violationThrField.Layout.Row = 2;

    slider = uislider(app.Metrics.controlGridArr(uiPos), "range", ...
        'Value',[1 100], 'Limits',[0 100],...
        'ValueChangingFcn',{@scrubSliderMoving, ax});
    slider.Layout.Row = 1;
    slider.Layout.Column = [1 3];

    if strcmp(whichSide, 'left')
        autosplitButton = uibutton(app.Metrics.controlGridArr(uiPos),...
            'Text', 'Autosplit violations below (ms):',...
            'ButtonPushedFcn', {@splitISI, app, ax, violationThrField});
        autosplitButton.Layout.Column = 1;
        autosplitButton.Layout.Row = 2;
    end
else
    app.Metrics.controlGridArr(uiPos).Children(1).Text =...
         "# violations: " + string(sum(ISI ...
         < app.Metrics.controlGridArr(uiPos).Children(2).Value));
end

end

%% callbacks
function scrubSliderMoving(~, event, ax)
if event.Value(1) ~= event.Value(2)
    xlim(ax,[event.Value(1) event.Value(2)]);
end
end


function updateViolations(~, event, ax, label)
label.Text = "# violations: " + string(sum(ax.UserData < event.Value));
end


% split violating spikes
function splitISI(~, ~, app, ax, threshObj)
violations = ax.UserData < threshObj.Value;
if any(violations)
    app.unitArray = app.unitArray.unitSplitter(...
        str2double(app.LeftUnitDropDown.Value),violations);
end
app.updateDropdown();
app.standardUpdate;
end