function [c, t, orphanBool] = forceAdd(c, t, selectedIdx, rawSpikesTimes, orphanBool, clustNum, batchNum, offset, waves)

if ~isempty(selectedIdx)
	orphanSpikes = rawSpikesTimes(orphanBool);
	selectedSpikes = orphanSpikes(selectedIdx);
	orphanIdx = find(orphanBool);
	orphanBool(orphanIdx(selectedIdx)) = 0; %update orphan_ind
	
	if ~isfield(c,"unit_"+clustNum)
		c.clusters(length(c.clusters)+1)=clustNum;
		c.("unit_"+clustNum)= selectedSpikes + offset;
		c.("waves_"+clustNum)=waves;
		t.("spikeBatchNum_"+clustNum) = batchNum*ones(1,length(orphanIdx(selectedIdx)));
		t.("spikeIdxInBatch_"+clustNum) = orphanIdx(selectedIdx);
	else
		c.("unit_"+clustNum)= [c.("unit_"+clustNum) selectedSpikes + offset];
		c.("waves_"+clustNum)= [c.("waves_"+clustNum); waves];
		t.("spikeBatchNum_"+clustNum) = [t.("spikeBatchNum_"+clustNum) batchNum*ones(1,length(orphanIdx(selectedIdx)))];
		t.("spikeIdxInBatch_"+clustNum) = [t.("spikeIdxInBatch_"+clustNum) orphanIdx(selectedIdx)];
	end
end