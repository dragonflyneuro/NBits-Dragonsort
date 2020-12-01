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

% make figure window and set size
figs.f = figure;
set(figs.f, 'MenuBar', 'none');
set(figs.f, 'ToolBar', 'none');
figs.f.UserData{1} = app.d.devMatrix;
figs.f.UserData{2} = app.ScalingTable.Data.Scaling;
figs.f.UserData{3} = false(size(app.d.devMatrix'));

width = 1600;
height = 900;
set(figs.f, 'Position',  [(1920-width)/2, (1080-height)/2, width, height]);
yl = [min(app.w(:,:,app.p.m.mainCh),[],'all')-10, max(app.w(:,:,app.p.m.mainCh),[],'all')+10];

% get colourmaps and set up subplot formatting
unitNames = 1:length(app.p.unitArray);
numFigsX = 6;

cmap = distinguishable_colors(28);
cmap = cmap([2:3, 5:18, 20:end],:);
sp = ceil(length(unitNames)*2/numFigsX)+1;
subplott = @(m,n,userLine) subtightplot (m, n, userLine, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

numAssignedTotal = 0;

% get initial wave to unit assignments
[~,I] = min(app.d.devMatrix,[],2);


% make waves suplots
for ii=unitNames
    figs.spikeAx(ii) = subplott(sp,numFigsX,floor((ii-1)/numFigsX)*numFigsX+ii);
    iiCmap=cmap(rem(ii-1,25)+1,:);
    
    devBool = app.d.devMatrix(:,ii) < app.p.t.add2UnitThr(1)^2;
    devBoolUnit = devBool & (I == ii);
    numAssignedToUnit = nnz(devBoolUnit);
    
    % plot all lines but make it invisible
    figs.spikeP{ii} = plot(figs.spikeAx(ii),app.w(:,:,app.p.m.mainCh)','Color',iiCmap,'Visible','off');
    [figs.spikeP{ii}(devBoolUnit).Visible] = deal('on');
    figs.f.UserData{3}(ii,:) = devBoolUnit;
    
    hold(figs.spikeAx(ii),'on');
    
    % plot mean wave
    templateWave = mean(app.d.tempWavesSet{ii}(:,:,app.p.m.mainCh),1);
    plot(figs.spikeAx(ii),templateWave,'Color',[0.2 0.2 0.2],'LineWidth',1);
    
    % titling, axes labeling and limit setting
    unitVal=ii;
    figs.sptitle(ii) = title(figs.spikeAx(ii),"Unit "+ unitVal +...
        " - " + string(numAssignedToUnit),'Color',iiCmap);
    ylabel(figs.spikeAx(ii),"Amplitude (uV)");
    ylim(figs.spikeAx(ii),yl);
    
    % get total number of spikes assigned
    numAssignedTotal = numAssignedTotal + numAssignedToUnit;
end

% big figure title with updating spike assignment tally
figs.title = sgtitle(figs.f,"Drag the red bar on the histograms to assign spikes to units" + ...
    " - Assigned " + string(numAssignedTotal) + "/" + string(size(app.w,1)) + "ENTER to accept, close/ESC to quit");

% make deviation histogram subplots
for ii=unitNames
    figs.histosAx(ii) = subplott(sp,numFigsX,floor((ii-1)/numFigsX)*numFigsX+ii+numFigsX);
    disableDefaultInteractivity(figs.histosAx(ii));
    
    devScaled = app.d.devMatrix(:,ii);
    figs.histos(ii) = histogram(figs.histosAx(ii), devScaled, 'Linestyle','none','BinWidth',0.05);
    hold(figs.histosAx(ii),'on');
    
    xlim(xlim(figs.histosAx(ii)));
    ylim(ylim(figs.histosAx(ii)));
    
    axMax = ylim(figs.histosAx(ii));
    axMax = axMax(2);
    figs.userLine(ii) = plot(figs.histosAx(ii),[app.p.t.add2UnitThr(1)^2/figs.f.UserData{2}(ii),...
        app.p.t.add2UnitThr(1)^2/figs.f.UserData{2}(ii)], [0 axMax],'r'); % default scaling line
    figs.histosAx(ii).UserData = ii; % used for getting axes clicked
    figs.histos(ii).UserData = ii; % used for getting axes clicked
    
    % set up callbacks
    figs.userLine(ii).ButtonDownFcn = {@buttonDownHistos,figs,app,cmap};
    figs.histosAx(ii).ButtonDownFcn = {@buttonDownHistos,figs,app,cmap};
    figs.histos(ii).ButtonDownFcn = {@buttonDownHistos,figs,app,cmap};
    
    ylabel(figs.histosAx(ii),"Frequency");
    xlabel(figs.histosAx(ii),"Disimillarity");
end

[pressedEnter, figData] = getFigData(figs.f);

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
updateFigures(h,app);
end

%%
function [] = buttonUpHistos(~,~,h,app,cmap)
updateFigures(h,app);

numAssignedTotal = 0;

for ii = 1:length(h.spikeAx)
    iiCmap=cmap(rem(ii-1,25)+1,:);
    numAssignedToUnit = nnz(h.f.UserData{3}(ii,:));
    numAssignedTotal = numAssignedTotal + numAssignedToUnit;
    
    h.sptitle(ii) = title(h.spikeAx(ii),"Unit " + ii +...
        " - " + string(numAssignedToUnit),'Color',iiCmap);
end

h.title = sgtitle(h.f,"Drag the red bar on the histograms to assign spikes to units" + ...
    " - Assigned " + string(numAssignedTotal) + "/" + string(size(app.w,1)));
app.ScalingTable.Data.Scaling = h.f.UserData{2};
h.f.WindowButtonMotionFcn = [];
h.f.WindowButtonUpFcn = [];
end

%%
function h = updateFigures(h,app)
axNum = get(gca,'UserData');
ax = h.histosAx(axNum);
lAllowed = app.ScalingTable.Data.LossLock;
lAllowed(axNum) = true;
gAllowed = app.ScalingTable.Data.GainLock;
gAllowed(axNum) = true;

mousePoint = ax.CurrentPoint;
mousePoint = mousePoint(1,1);
if mousePoint <= 0
    mousePoint = eps;
end

scaler = app.p.t.add2UnitThr(1)^2/mousePoint;
devScaled = h.f.UserData{1};
devScaled(:,axNum) = app.d.devMatrix(:,axNum).*scaler;
for ii = 1:size(devScaled,1)
    if ~any(h.f.UserData{3}(:,ii)) || lAllowed(h.f.UserData{3}(:,ii))
        [~, idx] = sort(devScaled(ii,:));
        for jj = idx
            if devScaled(ii,jj) < app.p.t.add2UnitThr(1)^2 && gAllowed(jj)
                h.f.UserData{3}(:,ii) = false;
                h.f.UserData{3}(jj,ii) = true;
                break;
            end
        end
    end
end

h.f.UserData{1} = devScaled;
h.f.UserData{2}(axNum) = scaler;
for ii = 1:length(h.spikeP)
    [h.spikeP{ii}(h.f.UserData{3}(ii,:)).Visible] = deal('on');
    [h.spikeP{ii}(~h.f.UserData{3}(ii,:)).Visible] = deal('off');
end

h.userLine(axNum).XData = [mousePoint,mousePoint];
end