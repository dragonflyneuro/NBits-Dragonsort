function [c, t] = prevTemplateMatch2(m, c, t, orphanSpikes, orphanWaves, X, batchNum, offset)
orphanSpikes = orphanSpikes(t.orphanBool{batchNum});
orphanWaves = orphanWaves(t.orphanBool{batchNum},:,:);
orphanIdx = find(t.orphanBool{batchNum});

[spikeClust,~] = TemplateDist2(m, c, t, orphanWaves, orphanSpikes, X, m.spikeWidth, m.oldTempSTDThreshold, m.sRateHz);
matchesIdx = (spikeClust~=0)'; %un-labelled spikes in the original spike list
t.orphanBool{batchNum}(orphanIdx(matchesIdx)) = false;

for cc=1:length(c.clusters)
	cNum = c.clusters(cc);
	oneClust = spikeClust==str2double(cNum);
	[uniqueSpikes, I] = setdiff(orphanSpikes(oneClust) + offset,c.("unit_"+cNum)); %find the unique ones
	c.("unit_"+cNum)=[c.("unit_"+cNum) uniqueSpikes]; %appending to exisiting
	c.("waves_"+cNum)=[c.("waves_"+cNum); orphanWaves(I,:,:)];
	t.("spikeBatchNum_"+cNum)  =[t.("spikeBatchNum_"+cNum) ...
		batchNum*ones(1,length(uniqueSpikes))];
	t.("spikeIdxInBatch_"+cNum) = [t.("spikeIdxInBatch_"+cNum) orphanIdx(oneClust)];
end
t.spikeClust{batchNum}(orphanIdx) = spikeClust;
end