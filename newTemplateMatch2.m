function [c, t, orphanBool, sortingState] = newTemplateMatch2(m, c, t, rawWaves, rawSpikesTimes, orphanBool, clustNum, batchNum, tempWaves, offset, fuzzyBit)
orphanSpikes = rawSpikesTimes(orphanBool);
orphanWaves = rawWaves(orphanBool,:,:);
[matchesIdx,~,~] = TemplateMatch5(orphanWaves,tempWaves,m.sRateHz,m.newTempSTDThreshold^2,fuzzyBit); %TemplateMatch2(trace,tempWaves,m.sRate);
orphanIdx = find(orphanBool);
orphanBool(orphanIdx(matchesIdx)) = 0; %update orphan_ind

if ~isempty(matchesIdx)
	if ~isfield(c,"unit_"+clustNum)
		c.clusters(length(c.clusters)+1)=clustNum;
		c.("unit_"+clustNum)=orphanSpikes(matchesIdx) + offset;
		c.("waves_"+clustNum)=orphanWaves(matchesIdx,:,:);
		t.("spikeBatchNum_"+clustNum) = batchNum*ones(1,length(orphanIdx(matchesIdx)));
		t.("spikeIdxInBatch_"+clustNum) = orphanIdx(matchesIdx);
	else
		c.("unit_"+clustNum)= [c.("unit_"+clustNum) orphanSpikes(matchesIdx) + offset];
		c.("waves_"+clustNum)= [c.("waves_"+clustNum); orphanWaves(matchesIdx,:,:)];
		t.("spikeBatchNum_"+clustNum) = [t.("spikeBatchNum_"+clustNum) batchNum*ones(1,length(orphanIdx(matchesIdx)))];
		t.("spikeIdxInBatch_"+clustNum) = [t.("spikeIdxInBatch_"+clustNum) orphanIdx(matchesIdx)];
	end
end

% for mm=1:(m.halfWidth*2+1) %update the mask
% 	mask(orphanSpikes(matchesIdx)-splitPoint-m.halfWidth+m.maskOffset+mm)=zeros(length(matchesIdx),1);
% end

sortingState = [length(matchesIdx) length(orphanBool)];
end