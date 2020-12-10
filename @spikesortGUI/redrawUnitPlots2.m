function [] = redrawUnitPlots2(app, h, varargin)

hTrace = h(1);
h = h(2:3);

if nargin > 2
    updateFigs = varargin{1};
    if updateFigs == 1
        delete(app.lSelection); delete(app.pL); delete(app.pTL);
        for ii = 1:4
%             cla(app.spL(ii));
        end
        set(h(1),'UserData', {[],[]}); % reset selected spikes in left unit
        set(h(1),'ButtonDownFcn',[]);
    else
        delete(app.pR); delete(app.pTR);
        for ii = 1:4
%             cla(app.spR(ii));
        end
    end
else
    updateFigs = 1:2;
    delete(app.lSelection); delete(app.pL); delete(app.pR); delete(app.pTL); delete(app.pTR);
    set(h(1),'UserData', {[],[]}); % reset selected spikes in left unit
    set(h(1),'ButtonDownFcn',[]);
    for ii = 1:4
%         cla(app.spL(ii)); cla(app.spR(ii));
    end
end

c = app.currentBatch;
bl = app.t.batchLengths;

%   redraw spikes for each unit
app.StatusLabel.Value = "Redrawing units...";
% drawnow

d = ["<", ">"];
u = [str2double(app.LeftUnitDropDown.Value), str2double(app.RightUnitDropDown.Value)];
t = [app.LTitle, app.RTitle];

%    ii == 1 is left unit, ii == 2 is right unit
for ii = updateFigs
    tempWaves = [];
    if length(app.unitArray) >= u(ii) && ~isempty(app.unitArray(u(ii)).spikeTimes) % if there are spikes in the unit
        %    find spikes in selected batches
        plotBatch = c + [-round(app.PastbatchesField.Value), min([round(app.FuturebatchesField.Value), length(bl)-c])];
        [~,~,unitSpikesInPlotIdx] = app.unitArray(u(ii)).getAssignedSpikes(getBatchRange(app,plotBatch));
        if ii == 1
            app.plottedWavesIdx = unitSpikesInPlotIdx;
        end
        tempWaves = app.unitArray(u(ii)).waves(unitSpikesInPlotIdx,:,:);
        
        %    find how many spikes there were in the last 3 batches
        last3Batches = [0,0,0];
        for jj = min([c,3]):-1:1
            last3Batches(jj) = nnz(app.unitArray(u(ii)).getAssignedSpikes(getBatchRange(app,c+[-jj,-jj+1])));
        end
        
        if strcmpi("Junk",app.unitArray(u(ii)).tags)
            junkText = "  JUNK UNIT";
        else
            junkText = "";
        end
        t(ii).Value = string(length(app.unitArray(u(ii)).spikeTimes)) +...
            " spikes total, " + last3Batches(2) + "/" + last3Batches(2) +...
            "/" + last3Batches(1) + " spikes -2/-1/0 batches ago" + junkText;
        
        q = 1;
    elseif length(app.unitArray) >= u(ii) && ~isempty(app.unitArray(u(ii)).loadedTemplateWaves)
        tempWaves = app.unitArray(u(ii)).loadedTemplateWaves;
        t(ii).Value = "TEMPLATE SPIKES ONLY";
        q = 0;
    else
        t(ii).Value = "No spikes!";
    end
    
    %     If there are waveforms in the selected unit OR there are templates
    if ~isempty(tempWaves)
        %userdata{2} is for getting selected spikes in trace
        [unitSpikesInBatch,~,unitSpikesInBatchIdx] = app.unitArray(u(ii)).getAssignedSpikes(getBatchRange(app));
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
            h(ii).UserData{2} = unitSpikesInBatchIdx;
            app.pL = line(h(ii), -app.m.spikeWidth:app.m.spikeWidth, tempWaves(:,:,app.m.mainCh)');
            if q % if there are spikes in the unit
                set(app.pL, 'ButtonDownFcn', {@lineSelected, app, app.plottedWavesIdx, h(ii)}) % click on spikes callback
                app.pTL = line(hTrace, tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit),...
                    'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(u(ii)-1,25)+1,:));
                hTrace.Children = hTrace.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
                if size(app.xi,1) > 0 && app.PlotallchButton.Value
                    for jj = 1:size(app.xi,1)
                        line(app.spT(jj), -tempUnit*app.msConvert, app.xi(jj,tempUnit),...
                            'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(u(ii)-1,25)+1,:));
                    end
                end
                set(h(ii),'ButtonDownFcn',{@boxClick,app,app.plottedWavesIdx,h(ii)});
            end
        elseif ii == 2 % Right unit
            app.pR = line(h(ii), -app.m.spikeWidth:app.m.spikeWidth, tempWaves(:,:,app.m.mainCh)');
            if q % if left and right units are different
                app.pTR = line(hTrace, tempUnit*app.msConvert, app.xi(app.m.mainCh,tempUnit),...
                    'LineStyle', 'none', 'Marker', d(ii), 'Color', app.cmap(rem(u(ii)-1,25)+1,:));
                hTrace.Children = hTrace.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
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

end

%%    callback for selected spikes
function boxClick(~,evt,app, w, h)
if isempty(app.pUnassigned)
    return;
end
if app.interactingFlag(2) ~= 0
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
    
    selectedLine = false(size(X));
    % select orphans inside box
    for ii = 1:length(X)
        selectedLine(ii) = any(inpolygon(X{ii},Y{ii},xBox,yBox));
    end
    selectedLine = find(selectedLine);
    selectedSpike = w(selectedLine);
    drawnow
    
    % store selected spikes in UserData
    for qq = 1:length(selectedLine)
        alreadySelectedBool = ismember(h.UserData{1},selectedSpike(qq));
        if ~any(alreadySelectedBool)
            app.pL(selectedLine(qq)).LineStyle = ':';
            h.UserData{1} = [h.UserData{1}, selectedSpike(qq)];
        else
            app.pL(selectedLine(qq)).LineStyle = '-';
            h.UserData{1}(alreadySelectedBool) = [];
        end
    end
    delete(app.lSelection);
end
end

function lineSelected(src, ~, app, w, h)
if app.interactingFlag(2) ~= 0
    return;
end
selectedSpike = w(app.pL == src);
if strcmp(src.LineStyle, ':')
    src.LineStyle = '-';
    h.UserData{1}(h.UserData{1} ~= selectedSpike) = [];
else
    src.LineStyle = ':';
    h.UserData{1} = [h.UserData{1}, selectedSpike];
end

end