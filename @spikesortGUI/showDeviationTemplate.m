function [] = showDeviationTemplate(app, uiPos)
isSameMetric = strcmp(app.Metrics.controlGridArr(uiPos).UserData, ...
    app.Metrics.dropDownArr(uiPos).Value);

if isSameMetric
    ax = app.Metrics.panelArr(uiPos).Children(2);
    plotLoadedFlag = app.Metrics.controlGridArr(uiPos).Children.Value;
    cla(ax);
else
    delete(app.Metrics.panelArr(uiPos).Children);
    delete(app.Metrics.controlGridArr(uiPos).Children);

    app.Metrics.gridArr(uiPos).RowHeight = {22,'1x',22};
    app.Metrics.controlGridArr(uiPos).RowHeight = {'1x'};
    app.Metrics.controlGridArr(uiPos).ColumnWidth = {'1x'};
    ax = axes('Parent',app.Metrics.panelArr(uiPos));

    uibutton(app.Metrics.controlGridArr(uiPos), "state", ...
        "Text","Show loaded template (dotted line)",...
        "ValueChangedFcn",{@buttonToggled, app, ax});
    plotLoadedFlag = 0;

    app.Metrics.controlGridArr(uiPos).UserData = app.Metrics.dropDownArr(uiPos).Value;
end
hold(ax,"on")

yRange = [0 1];
x = -app.m.spikeWidth:app.m.spikeWidth;
stdevX = [x, fliplr(x)];
cc = 1;

uIdx = [str2double(app.LeftUnitDropDown.Value), str2double(app.RightUnitDropDown.Value)];
if uIdx(1) == uIdx(2)
    uIdx = uIdx(1);
end
for ii = uIdx
    templateWaves = getTemplateWaves(app, ii);
    if ~isempty(templateWaves)
        templateWaves = templateWaves(:,:,app.m.mainCh);
        meanTemplate = mean(templateWaves,1);

        stdev = std(templateWaves,0,1);
        stdevLine1 = meanTemplate + stdev;
        stdevLine2 = meanTemplate - stdev;
        stdevBtwn = [stdevLine1, fliplr(stdevLine2)];

        fill(ax,stdevX,stdevBtwn,getColour(ii),'FaceAlpha',0.3,'EdgeColor','none');
        unitLines(cc) = line(ax,x,meanTemplate,'Color',getColour(ii),'LineWidth',2);
        legendSpec{cc} = "Unit "+ ii;

        yRange = [min([yRange(1),min(meanTemplate)]), max([yRange(2),max(meanTemplate)])];
        cc = cc + 1;
    end
end
if plotLoadedFlag
    plotLoaded(app, ax)
end

formatWaveAxes(app,ax,yRange)
if ~isempty(unitLines)
    legend(ax,unitLines,legendSpec)
end
ylabel(ax,'Amplitude (with standard deviation)')

end


%% subfunctions
function plotLoaded(app, ax)
uIdx = [str2double(app.LeftUnitDropDown.Value), str2double(app.RightUnitDropDown.Value)];
if uIdx(1) == uIdx(2)
    uIdx = uIdx(1);
end
x = -app.m.spikeWidth:app.m.spikeWidth;
for ii = uIdx
    y = app.unitArray(ii).loadedTemplateWaves;
    if ~isempty(y)
        line(ax,x,mean(y(:,:,app.m.mainCh),1),'Color',getColour(ii),...
            'LineWidth',2,'LineStyle','.');
    end
end
end


%% callbacks
function buttonToggled(~, event, app, ax)
if event.Value == 1
    plotLoaded(app, ax)
else
    delete(findobj(ax,'Type','line','LineStyle','.'))
end
end