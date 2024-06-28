function [] = showXCorr(app, uiPos)
delete(app.Metrics.panelArr(uiPos).Children);
delete(app.Metrics.controlGridArr(uiPos).Children);
app.Metrics.gridArr(uiPos).RowHeight = {22,'1x',0};
app.Metrics.controlGridArr(uiPos).UserData = app.Metrics.dropDownArr(uiPos).Value;

uIdx = [str2double(app.LeftUnitDropDown.Value), str2double(app.RightUnitDropDown.Value)];
t = tiledlayout(app.Metrics.panelArr(uiPos),2,2);
t.TileSpacing = "tight";
t.Padding = "compact";

for row = 1:2
    for col = 1:2
        ax = nexttile(t);
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
    end

end