function d = refinePlot(X, m, c, t, rawSpikeIdx, rawSpikeWaves, currentBatch, exception, f, p, d)
%% display the sorting result

msConvert = m.sRateHz/1000;
cmap = distinguishable_colors(28);
cmap = cmap([2:3, 5:18, 20:end],:);
limit = 0.0001;
hitLimit = d.scaleArray == limit;
clf(f);
sp = ceil(length(c.clusters)/7)+1;
subplott = @(m,n,p) subtightplot (m, n, p, [0.02 0.03], [0.05 0.1], [0.05 0.05]);
subplott(sp,7,sp*7+(-6:0)); line(msConvert*(1:size(X,2)),X(m.mainCh,:),'Color','b'); hold on;
line(rawSpikeIdx(d.spikeClusters == 0)*msConvert, X(1,rawSpikeIdx(d.spikeClusters == 0)),'LineStyle','none', 'Color','k', 'Marker','x');
tally = 0;
preAssignedNum = 0;

for ii=1:length(c.clusters)
	subplott(sp,7,ii);
	clustVal=str2double(c.clusters(ii)); iiCmap=cmap(ii,:); 
	spikesInClustIdx = find(d.spikeClusters==clustVal);
	spikesInClustTime = rawSpikeIdx(spikesInClustIdx); %the actual time index
	spike_template = d.tempWavesSet{ii}(:,:,m.mainCh);
	spike_addition = setdiff(spikesInClustIdx,find(d.clustersPrev==clustVal));
	spike_deletion = setdiff(find(d.clustersPrev==clustVal),spikesInClustIdx);
	spike_retained = intersect(spikesInClustIdx,find(d.clustersPrev==clustVal));
	plot(spike_template','Color',[0.8 0.8 0.8]); hold on;
	if ~isempty(spike_retained); plot(rawSpikeWaves(spike_retained,:,m.mainCh)','Color',[0.5 0.5 0.5]); end
	if ~isempty(spike_deletion); plot(rawSpikeWaves(spike_deletion,:,m.mainCh)','Color','k'); end
	if ~isempty(spike_addition); plot(rawSpikeWaves(spike_addition,:,m.mainCh)','Color',iiCmap); end
	yTemp(ii,:) = ylim;
	switch rem(floor(ii/(size(cmap,1)+1)),5)
		case 0
			ms = "x";
		case 1
			ms = "+";
		case 2
			ms = "square";
		case 3
			ms = "o";
		case 4
			ms = "diamond";
	end
	title("Unit "+clustVal+" "+ms+" ("+length(spikesInClustIdx)+")",'Color',iiCmap);
	
	subplott(sp,7,sp*7+(-6:0));
	line(spikesInClustTime*msConvert, X(m.mainCh,spikesInClustTime), 'LineStyle','none', 'Marker', ms, 'Color', iiCmap);
	
	if p
		tempUnit = t.rawSpikeIdx{currentBatch}(t.spikeClust{currentBatch} == ii);
		line(tempUnit*msConvert, X(m.mainCh,tempUnit), 'LineStyle', 'none', 'Marker', ms, 'Color', iiCmap);
		preAssignedNum = preAssignedNum + length(tempUnit);
		tally = tally + length(tempUnit);
	end
	tally = tally + length(spikesInClustIdx);
end

yTemp = [min(yTemp(:,1)), max(yTemp(:,2))];
for ii = 1:length(c.clusters)
	subplott(sp,7,ii)
	ylim(gca, yTemp);
	yticks(gca, 200*floor(yTemp(1)/200):200:200*ceil(yTemp(2)/200));
	xlim(gca, [1 size(rawSpikeWaves,2)]);
	set(gca,'xTick',[], 'YGrid', 'on', 'XGrid', 'off');
end

if ~isempty(exception)
	sgtitle({"Spikes assigned: "+tally+";  Spikes leftover: "+(length(rawSpikeIdx) + preAssignedNum - tally),...
		"Exceptions: "+sprintf('%s ',c.clusters(exception))+";  Scaling limit: "+sprintf('%s ',c.clusters(hitLimit))});
else
	sgtitle({"Spikes assigned: "+tally+";  Spikes leftover: "+(length(rawSpikeIdx) + preAssignedNum - tally),...
		"Scaling limit: "+sprintf('%s ',c.clusters(hitLimit))});
	
end

end