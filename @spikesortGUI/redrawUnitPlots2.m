function [] = redrawUnitPlots2(app,h)
c = app.currentBatch;
bl = app.t.batchLengths;

%   redraw spikes for each unit
app.StatusLabel.Value = "Redrawing units...";
% drawnow

%    setup
delete(app.lSelection); delete(app.pL); delete(app.pR); delete(app.pTL); delete(app.pTR);
for ii = 1:4
    cla(app.spL(ii)); cla(app.spR(ii));
end
h = [h(2), h(3), h(1)];
d = ["<", ">"];
u = [str2double(app.LeftUnitDropDown.Value), str2double(app.RightUnitDropDown.Value)];
set(h(1),'UserData', []); % reset selected spikes in left unit

app.lSelection = gobjects(1);

%    ii == 1 is left unit, ii == 2 is right unit
for ii = 1:2
    tempWaves = [];
    if length(app.unitArray) >= u(ii) && ~isempty(app.unitArray(u(ii)).spikeTimes) % if there are spikes in the unit
        %    find spikes in selected batches
        plotBatch = [-round(app.PastbatchesField.Value)-1, min([round(app.FuturebatchesField.Value), length(bl)-c])];
        [~,~,~,unitSpikesInPlotIdx] = app.unitArray(u(ii)).getAssignedSpikes(app.t,app.currentBatch,plotBatch);
        if ii == 1
            app.plottedWavesIdx = unitSpikesInPlotIdx;
        end
        tempWaves = app.unitArray(u(ii)).waves(unitSpikesInPlotIdx,:,:);
        
        %    find how many spikes there were in the last 3 batches
        for jj = 3:-1:1
            last3Batches(jj) = nnz(app.unitArray(u(ii)).getAssignedSpikes(app.t,app.currentBatch,[-jj,-jj+1]));
        end
        
        if strcmpi("Junk",app.unitArray(u(ii)).tags)
            junkText = "  JUNK UNIT";
        else
            junkText = "";
        end
        title(h(ii), string(length(app.unitArray(u(ii)).spikeTimes)) +...
            " spikes total, " + last3Batches(1) + "/" + last3Batches(2) +...
            "/" + last3Batches(3) + " spikes -2/-1/0 batches ago" + junkText)
        
        q = 1;
    elseif length(app.unitArray) >= u(ii) && ~isempty(app.unitArray(u(ii)).loadedTemplateWaves)
        tempWaves = app.unitArray(u(ii)).loadedTemplateWaves;
        title(h(ii), "TEMPLATE SPIKES ONLY")
        q = 0;
    else
        title(h(ii), "No spikes!")
    end
    
    %     If there are waveforms in the selected unit OR there are templates
    if ~isempty(tempWaves)
        %userdata{2} is for getting selected spikes in trace
        [unitSpikesInBatch,~,~,h(1).UserData{2}] = app.unitArray(u(ii)).getAssignedSpikes(app.t,app.currentBatch);
        tempUnit = unitSpikesInBatch - sum(bl(1:c-1));
        %      If the unit size is over the number to be plotted
        if size(tempWaves,1) > round(app.SpikeshownField.Value)
            tempWaves = tempWaves(end-round(app.SpikeshownField.Value)+1:end,:,:);
            if ~isempty(app.plottedWavesIdx) && ii == 1
                app.plottedWavesIdx = app.plottedWavesIdx(end-round(app.SpikeshownField.Value)+1:end);
            end
        end
        %      Draw units
        if ii == 1 % Left unit
            app.pL = line(h(ii), -app.m.spikeWidth:app.m.spikeWidth, tempWaves(:,:,app.m.mainCh)');
            if q % if there are spikes in the unit
                set(app.pL, 'ButtonDownFcn', {@lineSelected, app, app.plottedWavesIdx, h(1)}) % click on spikes callback
                app.pTL = line(h(3), tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit),...
                    'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(u(ii)-1,25)+1,:));
                h(3).Children = h(3).Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
                if size(app.xi,1) > 0 && app.PlotallchButton.Value
                    for jj = 1:size(app.xi,1)
                        line(app.spT(jj), -tempUnit*app.msConvert, app.xi(jj,tempUnit),...
                            'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(u(ii)-1,25)+1,:));
                    end
                end
                set(h(1),'ButtonDownFcn',{@boxClick,app,h(1)})
            end
        elseif ii == 2 % Right unit
            app.pR = line(h(ii), -app.m.spikeWidth:app.m.spikeWidth, tempWaves(:,:,app.m.mainCh)');
            if u(1) ~= u(2) && q % if left and right units are different
                app.pTR = line(h(3), tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit),...
                    'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(u(ii)-1,25)+1,:));
                h(3).Children = h(3).Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
                if size(app.xi,1) > 0 && app.PlotallchButton.Value
                    for jj = 1:size(app.xi,1)
                        line(app.spT(jj), -tempUnit*app.msConvert, app.xi(jj,tempUnit),...
                            'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(u(ii)-1,25)+1,:));
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

app.LeftUnitDropDown.FontColor = app.cmap(rem(u(1)-1,25)+1,:);
app.RightUnitDropDown.FontColor = app.cmap(rem(u(2)-1,25)+1,:);
app.StatusLabel.Value = "Ready";

% set up interactivity for box selection of lines

end

%%    callback for selected spikes
function boxClick(~,evt,app,h)
if isempty(app.pUnassigned)
    return;
end
% get clicked coordinates
u = evt.IntersectionPoint;
% if box corner not defined yet
if ~ishandle(app.lSelection)
    % get first box corner and draw crosshair
    app.lSelection = plot(h, u(1,1), u(1,2), 'r+', 'MarkerSize', 20);
else
    % get second box corner and draw box
    xBox = [app.lSelection.XData, u(1,1), u(1,1), app.lSelection.XData, app.lSelection.XData];
    yBox = [app.lSelection.YData, app.lSelection.YData, u(1,2), u(1,2), app.lSelection.YData];
    delete(app.lSelection);
    app.lSelection = plot(h, xBox, yBox, 'r');
    
    X = get(app.pL,'XData');
    Y = get(app.pL,'YData');
    
    selectedLine = zeros(size(X));
    % select orphans inside box
    for ii = 1:length(X)
        selectedLine(ii) = any(inpolygon(X{ii},Y{ii},xBox,yBox));
    end
    selectedLine = find(selectedLine);
    drawnow
    
    % store selected spikes in UserData
    for qq = 1:length(selectedLine)
        alreadySelectedBool = ismember(h.UserData{1},selectedLine(qq));
        if ~any(alreadySelectedBool)
            app.pL(selectedLine(qq)).LineStyle = ':';
            h.UserData{1} = [h.UserData{1}, selectedLine(qq)];
        else
            app.pL(selectedLine(qq)).LineStyle = '-';
            h.UserData{1}(alreadySelectedBool) = [];
        end
    end
    delete(app.lSelection);
end
end

function lineSelected(src, ~, app, w, h)
lineIdx = find(app.pL == src);
if strcmp(src.LineStyle, ':')
    src.LineStyle = '-';
    temp = get(h, 'UserData');
    h.UserData{1} = temp{1}(temp{1} ~= w(lineIdx));
else
    src.LineStyle = ':';
    temp = get(app.LeftUnit, 'UserData');
    h.UserData{1} = [temp{1} w(lineIdx)];
end

end