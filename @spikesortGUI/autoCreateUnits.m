function [] = autoCreateUnits(app, unassignedSpikes, unassignedWaves, y, thr, sRate, cutoff, k, direction, fuzzyBool, cropFactor, sampleW)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Calls template matching function for to generate a new unit and updates
% Dragonsort structures
%
% INPUT
% c = Dragonsort unit-wave structure
% t = Dragonsort unit construction structure
% unassignedWaves = waves to try and create units from
%		FORMAT rows: observations, columns: time samples, pages: channels
% y = amplitudes of peaks of each observation of unassignedWaves
% sRate = sampling rate
% unassignedInBatch = index of spikes in the batch that was used to create
%		unassignedWaves
% unassignedSpikes = spike indexes of unassignedWaves
% cutoff = amplitude cutoff for unassignedWaves to create units from
% direction = direction of cutoff
% fuzzyBool = allows adjustment of threshold based on deviation metric distribution
% 		FORMAT {1, 0}

% OUTPUT
% c = Dragonsort unit-wave structure
% t = Dragonsort unit construction structure
% numNewUnits = number of new units created
subplott = @(m,n,p,d) parentstp (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05],d);

d = 1;
assignedUnit = [];
    
if direction == 1
    potentialSpikesBool = y > cutoff;
    percentLimit = 0.2;
else
    potentialSpikesBool = y < cutoff;
    percentLimit = 0;
end

if nnz(potentialSpikesBool) <= length(potentialSpikesBool)*percentLimit
    return;
end

%% PCA step
unassignedWavesTrimmed = unassignedWaves(potentialSpikesBool,:,:);
if size(unassignedWavesTrimmed,1) < 2
    return;
end
croppedWaves = unassignedWavesTrimmed(:,ceil(size(unassignedWavesTrimmed,2)/2) + (round(-0.3*sRate/1000):round(0.3*sRate/1000)),:);
croppedWaves = croppedWaves(:,:);

PC = pca(croppedWaves);
PCwaves = croppedWaves*PC(:,1:3);
clust = kmeans(PCwaves',k);
uniqueClust = unique(clust);
potentialSpikeIdx = find(potentialSpikesBool);

%% Dev matching step
devIdx = inf(length(uniqueClust),size(unassignedWavesTrimmed,1));
for ii = 1:length(uniqueClust)
    templateWaves = unassignedWavesTrimmed(clust == uniqueClust(ii),:,:);
    if size(templateWaves,1) > 30
        [~,~,devIdx(d,:)] = deviationTemplateMatch(unassignedWavesTrimmed, templateWaves, sRate, thr, 0, cropFactor, sampleW);
        d = d+1;
    end
end
if ~all(isinf(devIdx))
    [devMins, devMinIdx] = min(devIdx,[],1);
    assigned = devMins < thr^2;
    assignedUnit = assigned.*devMinIdx;
end

uniqueAssignedUnit = unique(assignedUnit);
uniqueAssignedUnit(uniqueAssignedUnit == 0) = [];
% for ii = uniqueAssignedUnit
%     meanDev = mean(devMins(assignedUnit == uniqueAssignementUnit));
% end
% [~,I] = sort(meanDev);

%% UI and interactive elements
f = uifigure('Name','Autocreated units'); set(f, 'Position',  [200, 200, 900, 700], 'CloseRequestFcn', {@closeFig, app});
g = uigridlayout(f);
g.RowHeight = {'1x',22};
g.ColumnWidth = {'1x','1x','1x'};

sel = uieditfield(g,"text","Value",'[]','ValueChangedFcn', @parseToArray);
sel.Layout.Row = 2; sel.Layout.Column = 1;
a1 = uibutton(g, 'Text', 'Accept only selected',...
    'ButtonPushedFcn', {@accepted, app, f, assignedUnit, potentialSpikeIdx,unassignedSpikes,unassignedWaves, sel, 1});
a1.Layout.Row = 2; a1.Layout.Column = 2;
a2 = uibutton(g, 'Text', 'Accept all and set unselected as junk',...
    'ButtonPushedFcn', {@accepted, app, f, assignedUnit, potentialSpikeIdx,unassignedSpikes,unassignedWaves, sel, 0});
a2.Layout.Row = 2; a2.Layout.Column = 3;
pan = uipanel(g,'AutoResizeChildren','off');
pan.Layout.Row = 1; pan.Layout.Column = [1,3];


%% Plot units
maxNum = 800;
numCol = max([length(uniqueAssignedUnit), 6]);
numRow = ceil(length(uniqueAssignedUnit)/numCol)+1;

ax = gobjects(length(uniqueAssignedUnit),1);
yTemp = zeros(length(uniqueAssignedUnit),2); % to match ylim later

for ii=1:length(uniqueAssignedUnit)
    waves{ii} = unassignedWavesTrimmed(assignedUnit == uniqueAssignedUnit(ii),:,app.m.mainCh);
    if ~isempty(waves{ii}) && size(waves{ii},1) > maxNum
        waves{ii} = waves{ii}(1:maxNum);
    end
end

for ii=1:length(uniqueAssignedUnit)
    spikeWidth = (size(waves{ii},2)-1)/2;
    ax(ii) = subplott(numRow,numCol,ii,pan);
    if ~isempty(waves{ii})
        p = line(ax(ii), -spikeWidth:spikeWidth, waves{ii}');
        set(p, {'Color'}, num2cell(parula(size(waves{ii},1)),2));
    end
    yTemp(ii,:) = ylim(ax(ii));
end

% edit xlim and ylim of figures to match
yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
% yTemp(~isinf(yl)) = yl(~isinf(yl));

for ii = 1:length(uniqueAssignedUnit)
    spikeWidth = (size(waves{ii},2)-1)/2;
    iiCmap = getColour(ii);
    title(ax(ii), 'Unit '+string(length(app.unitArray)+ii)+" ("+size(waves{ii},1)+")",'Color',iiCmap);
    ylim(ax(ii), yTemp);
    yticks(ax(ii), 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
    if spikeWidth > 0
        xlim(ax(ii), [-spikeWidth spikeWidth]);
    end
    set(ax(ii),'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

sgtitle(pan,"Autocreated units - max " + string(maxNum) + " spikes plotted");

% simpler method - no checking
% for ii = 1:length(uniqueClust)
%     numAssigned = sum(clust == uniqueClust(ii));
%     if numAssigned < 30
%         clust(clust == uniqueClust(ii)) = 0;
%     end
% end
% assignedUnit = clust;


end

%% todo: break this out into another file
function h=parentstp(m,n,p,gap,marg_h,marg_w,parent,varargin)
%function h=subtightplot(m,n,p,gap,marg_h,marg_w,varargin)
%
% Functional purpose: A wrapper function for Matlab function subplot. Adds the ability to define the gap between
% neighbouring subplots. Unfotrtunately Matlab subplot function lacks this functionality, and the gap between
% subplots can reach 40% of figure area, which is pretty lavish.  
%
% Input arguments (defaults exist):
%   gap- two elements vector [vertical,horizontal] defining the gap between neighbouring axes. Default value
%            is 0.01. Note this vale will cause titles legends and labels to collide with the subplots, while presenting
%            relatively large axis. 
%   marg_h  margins in height in normalized units (0...1)
%            or [lower uppper] for different lower and upper margins 
%   marg_w  margins in width in normalized units (0...1)
%            or [left right] for different left and right margins 
%
% Output arguments: same as subplot- none, or axes handle according to function call.
%
% Issues & Comments: Note that if additional elements are used in order to be passed to subplot, gap parameter must
%       be defined. For default gap value use empty element- [].      
%
% Usage example: h=subtightplot((2,3,1:2,[0.5,0.2])
if (nargin<4) || isempty(gap),    gap=0.01;  end
if (nargin<5) || isempty(marg_h),  marg_h=0.05;  end
if (nargin<5) || isempty(marg_w),  marg_w=marg_h;  end
if isscalar(gap),   gap(2)=gap;  end
if isscalar(marg_h),  marg_h(2)=marg_h;  end
if isscalar(marg_w),  marg_w(2)=marg_w;  end
gap_vert   = gap(1);
gap_horz   = gap(2);
marg_lower = marg_h(1);
marg_upper = marg_h(2);
marg_left  = marg_w(1);
marg_right = marg_w(2);

%note n and m are switched as Matlab indexing is column-wise, while subplot indexing is row-wise :(
[subplot_col,subplot_row]=ind2sub([n,m],p);  

% note subplot suppors vector p inputs- so a merged subplot of higher dimentions will be created
subplot_cols=1+max(subplot_col)-min(subplot_col); % number of column elements in merged subplot 
subplot_rows=1+max(subplot_row)-min(subplot_row); % number of row elements in merged subplot   

% single subplot dimensions:
%height=(1-(m+1)*gap_vert)/m;
%axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
height=(1-(marg_lower+marg_upper)-(m-1)*gap_vert)/m;
%width =(1-(n+1)*gap_horz)/n;
%axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;
width =(1-(marg_left+marg_right)-(n-1)*gap_horz)/n;

% merged subplot dimensions:
merged_height=subplot_rows*( height+gap_vert )- gap_vert;
merged_width= subplot_cols*( width +gap_horz )- gap_horz;

% merged subplot position:
merged_bottom=(m-max(subplot_row))*(height+gap_vert) +marg_lower;
merged_left=(min(subplot_col)-1)*(width+gap_horz) +marg_left;
pos_vec=[merged_left merged_bottom merged_width merged_height];

% h_subplot=subplot(m,n,p,varargin{:},'Position',pos_vec);
% Above line doesn't work as subplot tends to ignore 'position' when same mnp is utilized
h=subplot('Position',pos_vec,'Parent',parent,varargin{:});

if (nargout < 1),  clear h;  end

end


%% callbacks
function accepted(~, ~, app, f, ass, candidates, unassignedSpikes, unassignedWaves, sel, flag)
uAss = unique(ass);
uAss(uAss == 0) = [];
selected = eval(sel.Value)-length(app.unitArray);
for ii = uAss
    if ismember(ii, selected)
        I = ass == ii;
        tempU = unit(unassignedSpikes(candidates(I)), unassignedWaves(candidates(I),:,:));
        app.unitArray = [app.unitArray, tempU];
    elseif ~flag
        I = ass == ii;
        tempU = unit(unassignedSpikes(candidates(I)), unassignedWaves(candidates(I),:,:));
        tempU.tags = "Junk";
        app.unitArray = [app.unitArray, tempU];
    end
end

app.updateDropdown();
app.standardUpdate;
close(f)
end

function v = parseToArray(src, ~)
N = regexp(src.Value,'\d*','Match');
v = '';
for ii = 1:length(N)
    v = [v num2str(N{ii}) ','];
end
src.Value = ['[' v(1:end-1) ']'];
end

function closeFig(src, ~, app)
app.switchButtons('menuOn');
app.switchButtons('opsOn');
delete(src)
end