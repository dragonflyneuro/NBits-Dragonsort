function d = deviationRefine(c, t, rawSpikeWaves, templateBatches, numTemplates, sRate, scaleArray, d)
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

thr = t.add2UnitThr(1);

if isfield(d, 'devMatrix')
    devMatrix = d.devMatrix;
    prevAssignment = d.spikeAssignmentUnit; %keep the very last spike assignment for reference
else
    [devMatrix, d.tempWavesSet] = getDevMatrix(c, t, c.clusters, templateBatches, rawSpikeWaves, sRate, numTemplates, 0);
    prevAssignment = zeros(size(rawSpikeWaves,1),1);
end

spikeAssignmentUnit=zeros(size(rawSpikeWaves,1),1); %reinitialize the spike_clusters
%% determine the template deviation cutoff

for ii=1:length(c.clusters)
    devScaled(:,ii)=devMatrix(:,ii)*scaleArray(ii); %scale the deviation matrix
end
[reassigned, ~] = find(devScaled < thr^2);
tempDev = devScaled(reassigned,:); %gather all the spikes that can be distributed
[~,redisClustNum] = min(tempDev,[],2); %make sure we go for the minimum deviation

if ~isempty(reassigned)
    for ii=1:size(reassigned,1) %go through each spike that can be distributed; we don't attempt to update structure c here
        clustName=c.clusters(redisClustNum(ii));
        spikeAssignmentUnit(reassigned(ii))=str2double(clustName); %distribute the spike
    end
end

d.prevAssignment = prevAssignment;
d.spikeAssignmentUnit = spikeAssignmentUnit;
d.devMatrix = devMatrix;

end