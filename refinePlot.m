function f = refinePlot(X, m, unitNames, rawSpikeIdx, orphanWaves, preAssignment, f,  d, yL)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Plots the results of each round of spike sorting refine process with
% Dragonsort
%
% INPUT
% X = raw ephys data trace
% m = Dragonsort metadata structure
% unitNames = string names of each unit that is being refined
% rawSpikeIdx = spike indices along X
% orphanWaves = waves to be refined into units
%		FORMAT rows: observations, columns: time samples, pages: channels
% preAssignment = pre-refine assignments of spikes in rawSpikeIdx
% f = figure handle of previous refinePlot - makes things a bit faster
% d = Dragonsort refine structure
%
% OUTPUT
% f = figure handle of refinePlot

msConvert = m.sRateHz/1000;
cmap = distinguishable_colors(28);
cmap = cmap([2:3, 5:18, 20:end],:);
clf(f);
sp = ceil(length(unitNames)/7)+1;
subplott = @(m,n,p) subtightplot (m, n, p, [0.02 0.03], [0.05 0.1], [0.05 0.05]);
subplott(sp,7,sp*7+(-6:0)); line(msConvert*(1:size(X,2)),X(m.mainCh,:),'Color','b'); hold on;
line(rawSpikeIdx(d.spikeAssignmentUnit == 0)*msConvert, X(1,rawSpikeIdx(d.spikeAssignmentUnit == 0)),'LineStyle','none', 'Color','k', 'Marker','x');
xlim([1, size(X,2)*msConvert]); xlabel("Sample number"); ylabel("Amplitude (uV)");
tally = 0;
preAssignedNum = 0;

for ii=1:length(unitNames)
	subplott(sp,7,ii);
	unitVal=str2double(unitNames(ii)); iiCmap=cmap(rem(ii-1,25)+1,:);
	spikesInUnitIdx = find(d.spikeAssignmentUnit==unitVal);
	spikesInUnitTime = rawSpikeIdx(spikesInUnitIdx); %the actual time index
	templateWaves = d.tempWavesSet{ii}(:,:,m.mainCh);
	spikeAdded = setdiff(spikesInUnitIdx,find(d.prevAssignment==unitVal));
	spikeDeleted = setdiff(find(d.prevAssignment==unitVal),spikesInUnitIdx);
	spikeRetained = intersect(spikesInUnitIdx,find(d.prevAssignment==unitVal));
	plot(templateWaves','Color',[0.8 0.8 0.8]); hold on;
	if ~isempty(spikeRetained); plot(orphanWaves(spikeRetained,:,m.mainCh)','Color',[0.5 0.5 0.5]); end
	if ~isempty(spikeDeleted); plot(orphanWaves(spikeDeleted,:,m.mainCh)','Color','k'); end
	if ~isempty(spikeAdded); plot(orphanWaves(spikeAdded,:,m.mainCh)','Color',iiCmap); end
	yTemp(ii,:) = ylim;
	ms = getMarker(size(cmap,1),ii);
	title("Unit "+unitVal+" "+ms+" ("+length(spikesInUnitIdx)+")",'Color',iiCmap);
	
	subplott(sp,7,sp*7+(-6:0));
	line(spikesInUnitTime*msConvert, X(m.mainCh,spikesInUnitTime), 'LineStyle','none', 'Marker', ms, 'Color', iiCmap);
	
	if size(orphanWaves,1) ~= length(rawSpikeIdx)
		currentUnit = rawSpikeIdx(preAssignment == unitVal);
		line(currentUnit*msConvert, X(m.mainCh,currentUnit), 'LineStyle', 'none', 'Marker', ms, 'Color', iiCmap);
		preAssignedNum = preAssignedNum + length(currentUnit);
		tally = tally + length(currentUnit);
	end
	tally = tally + length(spikesInUnitIdx);
end

yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
if ~isinf(yL(1))
    yTemp(1) = yL(1);
end
if ~isinf(yL(2))
    yTemp(2) = yL(2);
end
for ii = 1:length(unitNames)
	subplott(sp,7,ii)
	ylim(gca, yTemp);
	yticks(gca, 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
	xlim(gca, [1 size(orphanWaves,2)]);
	set(gca,'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
	if ii == 1
		ylabel("Amplitude (uV)");
	end
end
sgtitle({"Spikes assigned: "+tally+";  Spikes leftover: "+(length(rawSpikeIdx) + preAssignedNum - tally)});

end