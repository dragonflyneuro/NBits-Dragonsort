function [devMatrix, tempWavesSet, spikeAssignment] = newDeviationRefine(thr, uA, orphanWaves, range, numTemplates, sRate, scalings)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Calculates the deviation indices of unassigned waves to the currently
% present units in Dragonsort. Then scales the deviation indices up/down
% by a multiplier, getting further/closer to the assignment threshold
%
% INPUT
% c = Dragonsort unit-wave structure
% t = Dragonsort unit construction structure
% rawSpikeWaves = waves to match to templates of current units
%		FORMAT rows: observations, columns: time samples, pages: channels
% templateBatches = the range of batches to take unit templates from
% numTemplates = number of waves to form a template with from each unit
% sRate = sampling rate
% scalingArray = scaling factors for each unit
% d = Dragonsort refine structure
%
% OUTPUT
% d = Dragonsort refine structure

[devMatrix, tempWavesSet] = newGetDevMatrix(thr, uA, orphanWaves, range, numTemplates, sRate, 0);
spikeAssignment = false(size(orphanWaves,1),length(uA)); %reinitialize the spike_clusters
%% determine the template deviation cutoff
for ii = 1:length(uA)
    devScaled(:,ii) = devMatrix(:,ii)/scalings(ii);
end
[~,minimumDevIdx] = min(devScaled,[],2); %make sure we go for the minimum deviation
candidateBool = devScaled < thr^2;
for ii = 1:size(candidateBool,1)
    if candidateBool(ii,minimumDevIdx(ii))
        spikeAssignment(ii,minimumDevIdx(ii)) = true;
    end
end

end