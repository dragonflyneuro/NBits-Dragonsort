function [] = redrawUnitPlots(app)
c = app.currentBatch;
bl = app.t.batchLengths;

%   redraw spikes for each unit
app.StatusLabel.Value = "Redrawing units...";
drawnow

%    setup
delete(app.pL); delete(app.pR); delete(app.pTL); delete(app.pTR);
for ii = 1:4
    cla(app.spL(ii)); cla(app.spR(ii));
end
app.plottedWavesIdx = [];
h = [app.LeftUnit app.RightUnit];
d = ["<", ">"];
u = [string(app.LeftUnitDropDown.Value), string(app.RightUnitDropDown.Value)];
set(h(1),'UserData', []); % reset selected spikes in left unit

%    ii == 1 is left unit, ii == 2 is right unit
for ii = 1:2
    tempWaves = [];
    if isfield(app.s, "unit_"+u(ii)) && ~isempty(app.s.("unit_"+u(ii))) % if there are spikes in the unit
        %    find spikes in selected batches
        plotBatch = [-round(app.PastbatchesField.Value), min([round(app.FuturebatchesField.Value), length(bl)-c])];
        unitSpikesInPlotIdx = find(sum(bl(1:c-1+plotBatch(1))) < app.s.("unit_"+u(ii))...
            & app.s.("unit_"+u(ii)) <= sum(bl(1:c+plotBatch(2))));
        if ii == 1
            app.plottedWavesIdx = unitSpikesInPlotIdx;
        end
        tempWaves = app.s.("waves_"+u(ii))(unitSpikesInPlotIdx,:,:);
        
        %    find how many spikes there were in the last 3 batches
        for jj = 3:-1:1
            last3Batches(jj) = nnz(sum(bl(1:c-jj)) < app.s.("unit_"+u(ii)) ...
                & app.s.("unit_"+u(ii)) <= sum(bl(1:c-jj+1)));
        end
        
        if app.s.tags("Junk",:).("unit_"+u(ii)) == 1
            junkText = "  JUNK UNIT";
        else
            junkText = "";
        end
        title(h(ii), string(length(app.s.("unit_"+u(ii)))) +" spikes total, " + last3Batches(1) + "/" + last3Batches(2)...
            + "/" + last3Batches(3) + " spikes -2/-1/0 batches ago" + junkText)
        
        q = 1;
    elseif isfield(app.t,("importedTemplateMapping")) && any(strcmp(u(ii), app.t.importedTemplateMapping{2}(:,1)))
        tempWaves = app.t.("template_"+app.t.importedTemplateMapping{2}(strcmp(u(ii), app.t.importedTemplateMapping{2}(:,1)),2));
        title(h(ii), "TEMPLATE SPIKES ONLY")
        q = 0;
    else
        title(h(ii), "No spikes!")
    end
    
    %     If there are waveforms in the selected unit OR there are templates
    if ~isempty(tempWaves)
        unitSpikesInBatchBool = sum(bl(1:c-1)) < app.s.("unit_"+u(ii)) & app.s.("unit_"+u(ii)) <= sum(bl(1:c));
        tempUnit = app.s.("unit_"+u(ii))(unitSpikesInBatchBool) - sum(bl(1:c-1));
        %      If the unit size is over the number to be plotted
        if size(tempWaves,1) > round(app.SpikeshownField.Value)
            tempWaves = tempWaves(end-round(app.SpikeshownField.Value)+1:end,:,:);
            if ~isempty(app.plottedWavesIdx) && ii == 1
                app.plottedWavesIdx = app.plottedWavesIdx(end-round(app.SpikeshownField.Value)+1:end);
            end
        end
        %      Draw units
        if ii == 1 % Left unit
            app.lUnitInBatchIdx = find(unitSpikesInBatchBool);
            app.pL = line(h(ii), -app.m.spikeWidth:app.m.spikeWidth, tempWaves(:,:,app.m.mainCh)');
            if q % if there are spikes in the unit
                set(app.pL, 'ButtonDownFcn', {@lineSelected, app, app.plottedWavesIdx}) % click on spikes callback
                app.pTL = line(app.Trace, tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit),...
                    'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(str2double(u(ii))-1,25)+1,:));
                app.Trace.Children = app.Trace.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
                if size(app.xi,1) > 0 && app.PlotallchButton.Value
                    for jj = 1:size(app.xi,1)
                        line(app.spT(jj), -tempUnit*app.msConvert, app.xi(jj,tempUnit),...
                            'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(str2double(u(ii))-1,25)+1,:));
                    end
                end
            end
        elseif ii == 2 % Right unit
            app.pR = line(h(ii), -app.m.spikeWidth:app.m.spikeWidth, tempWaves(:,:,app.m.mainCh)');
            if ~strcmp(u(1), u(2)) && q % if left and right units are different
                app.pTR = line(app.Trace, tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit),...
                    'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(str2double(u(ii))-1,25)+1,:));
                app.Trace.Children = app.Trace.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
                if size(app.xi,1) > 0 && app.PlotallchButton.Value
                    for jj = 1:size(app.xi,1)
                        line(app.spT(jj), -tempUnit*app.msConvert, app.xi(jj,tempUnit),...
                            'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(str2double(u(ii))-1,25)+1,:));
                    end
                end
            end
        end
        
        if size(app.xi,1) > 0 && app.PlotallchButton.Value
            for jj = 1:size(app.xi,1)
                line(app.spL(jj), -app.m.spikeWidth:app.m.spikeWidth, tempWaves(:,:,jj)');
            end
        end
        
        %      prettify axes
        if ~isinf(app.yLimLowField.Value)
            yl(1) = app.yLimLowField.Value;
        else
            yl(1) = min(min(tempWaves(:,:,app.m.mainCh)))-50;
        end
        if ~isinf(app.yLimHighField.Value)
            yl(2) = app.yLimHighField.Value;
        else
            yl(2) = max(max(tempWaves(:,:,app.m.mainCh)))+50;
        end
        
        step = 50*ceil((yl(2) - yl(1))/500);
        ticks = unique([0:-step:50*floor(yl(1)/50), 0:step:50*floor(yl(2)/50)]);
        ylim(h(ii),yl);
        yticks(h(ii),ticks);
        set(h(ii), 'YGrid', 'on', 'XGrid', 'off')
    end
    
end

app.LeftUnitDropDown.FontColor = app.cmap(rem(str2double(u(1))-1,25)+1,:);
app.RightUnitDropDown.FontColor = app.cmap(rem(str2double(u(2))-1,25)+1,:);
app.StatusLabel.Value = "Ready";
drawnow
if isempty(app.lastStep)
    app.UndoredoMenu.Enable = 'off';
else
    app.UndoredoMenu.Enable = 'on';
end

end

%%    callback for selected spikes
function lineSelected(src, ~, app, w)
lineIdx = find(app.pL == src);
if strcmp(src.LineStyle, ':')
    src.LineStyle = '-';
    temp = get(app.LeftUnit, 'UserData');
    set(app.LeftUnit, 'UserData', temp(temp ~= w(lineIdx)));
else
    src.LineStyle = ':';
    temp = get(app.LeftUnit, 'UserData');
    set(app.LeftUnit, 'UserData', [temp w(lineIdx)]);
end

end