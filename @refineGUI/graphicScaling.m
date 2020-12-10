function [pressedEnter, figData] = graphicScaling(app)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Plots the results of each round of spike sorting refine process with
% Dragonsort
%
% INPUT
% X = raw ephys data trace
% app.p.m = Dragonsort metadata structure
% unitNames = string names of each unit that is being refined
% app.p.rawSpikeIdx = spike indices along X
% app.p.app.w = waves to be refined into units
%		FORMAT rows: observations, columns: time samples, pages: channels
% preAssignment = pre-refine assignments of spikes in app.p.rawSpikeIdx
% f = figure handle of previous refinePlot - makes things a bit faster
% d = Dragonsort refine structure
%
% OUTPUT
% f = figure handle of refinePlot

subplott = @(m,n,p) subtightplot (m, n, p, [0.02 0.015], [0.06 0.03], [0.025 0.025]);

% make figure window and set size
figs.f = figure;
set(figs.f, 'MenuBar', 'none');
set(figs.f, 'ToolBar', 'none');
figs.f.UserData{1} = app.ScalingTable.Data.Scaling;
figs.f.UserData{2} = app.d.spikeAssignmentUnit;

width = 1850;
height = 1000;
set(figs.f, 'Position',  [(1920-width)/2, (1080-height)/2, width, height]);

% get colourmaps and set up subplot formatting
unitNames = find(app.ScalingTable.Data.ShowLock)';
numCols = 6;

cmap = distinguishable_colors(28);
cmap = cmap([2:3, 5:18, 20:end],:);
sizeMulti = 5;
numRows = ceil(2*length(unitNames)/numCols)*sizeMulti+1;
if app.ShowtraceButton.Value == 1
    numRows = numRows+1;
end

% get initial wave to unit assignments
numAssignedTotal = 0;
yl = [-500, 200];

% TRACE
if app.ShowtraceButton.Value == 1
    figs.trace = subplott(numRows,numCols,[(numRows-2)*numCols+(floor(numCols/2)+1:numCols),...
        (numRows-1)*numCols+(floor(numCols/2)+1:numCols)]);
    line(figs.trace,1:size(app.p.xi,2),app.p.xi(app.p.m.mainCh,:));
    range = getBatchRange(app.CallingApp);
    orphanTimes = app.wTimes-range(1);
    line(figs.trace, orphanTimes, app.p.xi(app.p.m.mainCh,orphanTimes),...
        'Color', 'k', 'Marker', '.', 'LineStyle', 'none', 'MarkerSize',3);
    
    if app.LockoriginalButton.Value ~= 0
        for ii = unitNames
            iiCmap = cmap(rem(ii-1,25)+1,:);
            [ms, msSize] = getMarker(size(cmap,1), ii);
            unitSpikesInBatch = app.p.unitArray(ii).getAssignedSpikes(range);
            tempUnit = unitSpikesInBatch - range(1);
            line(figs.trace, tempUnit, app.p.xi(app.p.m.mainCh,tempUnit), ...
                'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize/2, 'Color', iiCmap);
        end
    end
    yticks(figs.trace,[]);
    xticks(figs.trace,[]);
    title(figs.trace, "Drag the red bar on the histograms to assign spikes to units");
    figs.assignedOnTrace = gobjects(size(unitNames));
end

% make waves suplots
for ii = unitNames
    iiCmap = cmap(rem(ii-1,25)+1,:);
    loc = 1+rem(ii-1,numCols/2)+sizeMulti*numCols*floor(2*(ii-1)/numCols);
    figs.spikeAx(ii) = subplott(numRows,numCols,[loc, loc+numCols*(sizeMulti-1)]);
    
    % plot all lines but make it invisible
    figs.spikeP{ii} = line(figs.spikeAx(ii),1:size(app.w,2),app.w(:,:,app.p.m.mainCh)',...
        'Visible','off');%,'Color',[iiCmap, 0.5]
    [figs.spikeP{ii}(figs.f.UserData{2}(:,ii)).Visible] = deal('on');
    
    hold(figs.spikeAx(ii),'on');
    
    % plot mean wave
    templateWave = mean(app.d.tempWavesSet{ii}(:,:,app.p.m.mainCh),1);
    plot(figs.spikeAx(ii),templateWave,'Color',[0.2 0.2 0.2],'LineWidth',1);
    yl(1) = min([yl(1), min(templateWave)-100]);
    yl(2) = max([yl(2), max(templateWave)+100]);
    
    % titling, axes labeling and limit setting
    xlim(figs.spikeAx(ii),[1,size(app.w,2)]);
    xticks(figs.spikeAx(ii),[]);
    if rem(ii,numCols/2) ~= 1
        yticks(figs.spikeAx(ii),[]);
    end
    figs.sptitle(ii) = title(figs.spikeAx(ii),"Unit "+ ii +...
        " - " + string(sum(figs.f.UserData{2}(:,ii))),'Color',iiCmap);
    
    if app.ShowtraceButton.Value == 1
        [ms, msSize] = getMarker(size(cmap,1), ii);
        wT = app.wTimes(figs.f.UserData{2}(:,ii)) - range(1);
        if ~isempty(wT)
            figs.assignedOnTrace(ii) = line(figs.trace, wT, app.p.xi(app.p.m.mainCh,wT), ...
                        'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize/2, 'Color', iiCmap);
        end
    end
            
    % get total number of spikes assigned
    numAssignedTotal = numAssignedTotal + sum(figs.f.UserData{2}(:,ii));
end
if ~isinf(app.p.yL(1))
    yl(1) = app.p.yL(1);
end
if ~isinf(app.p.yL(2))
    yl(2) = app.p.yL(2);
end
if app.ShowtraceButton.Value == 1
    ylim(figs.trace,yl);
end

% HISTOGRAM
xMax = 0;
for ii = unitNames
    iiCmap = cmap(rem(ii-1,25)+1,:);
    ylim(figs.spikeAx(ii),yl);
    
    loc = 1+rem(ii-1,numCols/2)+numCols/2+sizeMulti*numCols*floor(2*(ii-1)/numCols);
    figs.histosAx(ii) = subplott(numRows,numCols,[loc, loc+numCols*(sizeMulti-1)]);
    disableDefaultInteractivity(figs.histosAx(ii));
    
    if app.AutoButton.Value == 1
        binSize = min([0.01, 20/size(app.d.devMatrix,2)]);
    else
        binSize = app.histBinEditField.Value;
    end
    figs.histos(ii) = histogram(figs.histosAx(ii), app.d.devMatrix(:,ii), 'Linestyle','none','BinWidth',binSize);
    hold(figs.histosAx(ii),'on');
    
    xlim(figs.histosAx(ii),xlim(figs.histosAx(ii)));
    xMaxTemp = xlim(figs.histosAx(ii));
    xMax = max([xMaxTemp, xMax]);
    
    ylim(figs.histosAx(ii),ylim(figs.histosAx(ii)));
    yMax = ylim(figs.histosAx(ii));
    yMax = yMax(2);
    
    figs.userLine(ii) = plot(figs.histosAx(ii),[app.d.thr^2*figs.f.UserData{1}(ii),...
        app.d.thr^2*figs.f.UserData{1}(ii)], [1 yMax],'r'); % default scaling line
    set(figs.histosAx(ii), 'YScale', 'log')
    xlim(figs.histosAx(ii),[0 2]);
    xticks(figs.histosAx(ii),[]);
    title(figs.histosAx(ii),"Unit "+ ii, 'Color',iiCmap);
    
    figs.histosAx(ii).UserData = ii; % used for getting axes clicked
    figs.histos(ii).UserData = ii; % used for getting axes clicked
    
    % set up callbacks
    figs.userLine(ii).ButtonDownFcn = {@buttonDownHistos,figs,app,cmap};
    figs.histosAx(ii).ButtonDownFcn = {@buttonDownHistos,figs,app,cmap};
    figs.histos(ii).ButtonDownFcn = {@buttonDownHistos,figs,app,cmap};
end

% SLIDERS
if app.ShowtraceButton.Value == 1
    figs.histSlider = subplott(numRows,numCols,(numRows-1)*numCols+(1:floor(numCols/2)));
    figs.spikeSlider = subplott(numRows,numCols,(numRows-2)*numCols+(1:floor(numCols/2)));
    titleT = "Disimilarity histogram view range";
    labelT = [];
else
    figs.histSlider = subplott(numRows,numCols,(numRows-1)*numCols+(floor(numCols/2)+1:numCols));
    figs.spikeSlider = subplott(numRows,numCols,(numRows-1)*numCols+(1:floor(numCols/2)));
    labelT = "Disimilarity histogram view range";
    titleT = "Drag the red bar on the histograms to assign spikes to units";
end

makeROISlider(figs.histSlider,labelT,titleT,...
    [0, min([10,xMax])], 0:0.5:xMax, [0, 2],...
    @(x)setProp(figs.histosAx,@xlim,unitNames,x));

figs.title = makeROISlider(figs.spikeSlider,"Spike amplitude view range",...
    "Assigned " + string(numAssignedTotal) + "/" + string(size(app.w,1)) + "  ENTER to accept, close/ESC to quit",...
    [200*floor(yl(1)/200),200*ceil(yl(2)/200)], 200*floor(yl(1)/200):200:200*ceil(yl(2)/200), yl,...
    @(x)setProp(figs.spikeAx,@ylim,unitNames,x));

[pressedEnter, figData] = getFigData(figs.f);
end

%%
function [] = setProp(h,func,range,val)
for ii = range
    func(h(ii),val);
end
end

%%
function [] = buttonDownHistos(~,~,h,app,cmap)
axNum = get(gca,'UserData');
ax = h.histosAx(axNum);

mousePoint = ax.CurrentPoint;
mousePoint = mousePoint(1,1);
if mousePoint <= 0
    mousePoint = eps;
end

h.userLine(axNum).XData = [mousePoint,mousePoint];
% h.userLine(axNum).ButtonDownFcn = {@buttonDownHistos,h,in};

h.f.WindowButtonMotionFcn = {@buttonHeldHistos,h,app};
h.f.WindowButtonUpFcn = {@buttonUpHistos,h,app,cmap};
end

%%
function [] = buttonHeldHistos(~,~,h,app)
updateFigures(h,app,0);
end

%%
function [] = buttonUpHistos(~,~,h,app,cmap)
updateFigures(h,app,1);

numAssignedTotal = 0;
for ii = find(app.ScalingTable.Data.ShowLock)'
    iiCmap = cmap(rem(ii-1,25)+1,:);
    numAssignedTotal = numAssignedTotal + sum(h.f.UserData{2}(:,ii));
    
    h.sptitle(ii) = title(h.spikeAx(ii),"Unit " + ii +...
        " - " + string(sum(h.f.UserData{2}(:,ii))),'Color',iiCmap);
    
    if app.ShowtraceButton.Value == 1
        [ms, msSize] = getMarker(size(cmap,1), ii);
        range = getBatchRange(app.CallingApp);
        wT = app.wTimes(h.f.UserData{2}(:,ii)) - range(1);
        delete(h.assignedOnTrace(ii));
        if ~isempty(wT)
            h.assignedOnTrace(ii) = line(h.trace, wT, app.p.xi(app.p.m.mainCh,wT), ...
                        'LineStyle', 'none', 'Marker', ms, 'MarkerSize', msSize/2, 'Color', iiCmap);
        end
    end

end

h.title.String = " - Assigned " + string(numAssignedTotal) + "/" +...
    string(size(app.w,1)) + "  ENTER to accept, close/ESC to quit";
h.f.WindowButtonMotionFcn = [];
h.f.WindowButtonUpFcn = [];

end

%%
function h = updateFigures(h,app,mode)
axNum = get(gca,'UserData');
ax = h.histosAx(axNum);
lAllowed = app.ScalingTable.Data.LossLock & app.ScalingTable.Data.ShowLock;
lAllowed(axNum) = true;
gAllowed = app.ScalingTable.Data.GainLock & app.ScalingTable.Data.ShowLock;
gAllowed(axNum) = true;

mousePoint = ax.CurrentPoint;
mousePoint = mousePoint(1,1);
if mousePoint <= 0
    mousePoint = eps;
end
h.f.UserData{1}(axNum) = mousePoint/app.d.thr(1)^2;

devM = app.d.devMatrix;
for ii = 1:size(devM,1)
    if ~any(h.f.UserData{2}(ii,:)) || lAllowed(h.f.UserData{2}(ii,:))
        h.f.UserData{2}(ii,:) = false;
        [~, idx] = sort(devM(ii,:));
        for jj = idx
            if devM(ii,jj) < h.f.UserData{1}(jj)*app.d.thr(1)^2 && gAllowed(jj)
                h.f.UserData{2}(ii,jj) = true;
                break;
            end
        end
    end
end

if mode == 0
    range = axNum;
else
    range = find(app.ScalingTable.Data.ShowLock)';
end
for ii = range
    [h.spikeP{ii}(h.f.UserData{2}(:,ii)).Visible] = deal('on');
    [h.spikeP{ii}(~h.f.UserData{2}(:,ii)).Visible] = deal('off');
end

h.userLine(axNum).XData = [mousePoint,mousePoint];
end