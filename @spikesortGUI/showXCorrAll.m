function [] = showXCorrAll(app, uiPos)
isSameMetric = strcmp(app.Metrics.controlGridArr(uiPos).UserData, ...
    app.Metrics.dropDownArr(uiPos).Value);

if isSameMetric
    ax = app.Metrics.panelArr(uiPos).Children;
    for ii = 1:length(ax)
        cla(ax(ii));
    end
else
    delete(app.Metrics.panelArr(uiPos).Children);
    delete(app.Metrics.controlGridArr(uiPos).Children);

    app.Metrics.gridArr(uiPos).RowHeight = {22,'1x',22};
    app.Metrics.controlGridArr(uiPos).RowHeight = {'1x'};
    app.Metrics.controlGridArr(uiPos).ColumnWidth = {'1x','1x','1x','1x'};
    app.Metrics.controlGridArr(uiPos).UserData = app.Metrics.dropDownArr(uiPos).Value;

    t = tiledlayout(app.Metrics.panelArr(uiPos),2,2);
    t.TileSpacing = "tight";
    t.Padding = "compact";
    
    %controls
    unitSelectDropDown = gobjects(4);
    for ii = 1:4
        unitSelectDropDown(ii) = uidropdown(app.Metrics.controlGridArr(uiPos),...
            'Items', ["None", app.LeftUnitDropDown.Items], 'Value', app.LeftUnitDropDown.Items(ii));
        unitSelectDropDown.Layout.Column = ii;
    end

    for row = 1:4
        for col = 1:4
            ax(ii) = nexttile(t);
            refUnit = app.unitArray(uIdx(row)).spikeTimes;
            targetUnit = app.unitArray(uIdx(col)).spikeTimes;
            bSize = 1*app.m.sRateHz/1000; % in ms
            maxLag = 50*app.m.sRateHz/1000; % in ms

            bE = -maxLag:bSize:maxLag;
            bC = bE(1:end-1) + diff(bE(1:2))/2;
            cC = zeros(size(bC));

            for kk = 1:length(refUnit)
                lag = targetUnit - refUnit(kk);
                if row == col
                    cC = cC + histcounts(lag(lag~=0), bE);
                else
                    cC = cC + histcounts(lag, bE);
                end
            end
            cC = cC / max(cC);
            bar(ax, bC*1000/app.m.sRateHz, cC,'Linestyle','none','BarWidth', 1);
            ylim(ax, [0,1.1]);

            if row == 1
                title(ax,'Unit '+string(uIdx(col)),'Color', getColour(uIdx(col)));
                set(ax,'XTickLabel',[]);
            end
            if row == 2
                xlabel(ax,'Lag (ms)');
            end
            if col == 1
                ylabel(ax,'Unit '+string(uIdx(row)),'Color',getColour(uIdx(row)),...
                    'FontWeight','bold');
            end
            if col == 2
                set(ax,'YTickLabel',[]);
            end
            cc = cc + 1;
        end

    end

end