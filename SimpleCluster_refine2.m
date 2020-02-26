%%%% SimpleCluster_refine
%%%% Huai-Ti Lin [July 2019]
%%%% This script takes the output from SimpleCluster_match3b.m and update
%%%% the spike_clusters spike assignement ”spike_clusters” into "spike_clusters_tuned"
%%%% A scaling vector u is introduced to scale the deviation matrix from which a single template matching threshold is applied.
%%%% By scaling the deviation for each template differentially, one
%%%% effectively modulate the tolerance of matching for each template.

function d = SimpleCluster_refine2(m, c, t, rawSpikeIdx, rawSpikeWaves, currentBatch, scaleDir, scaling, exception, d)
STDthresh=m.oldTempSTDThreshold;
% waveformXRange = 0:(size(rawSpikeWaves,2)-1)-ceil(size(rawSpikeWaves,2)/2);

if exist('d','var') && ~isempty(d)
	dMatrix = d.devMatrix;
	scaleArray = d.scaleArray;
	clustersPrev = d.spikeClusters; %keep the very last spike assignment for reference
else
	[dMatrix,~, d.tempWavesSet]=devMatrix2(m, c,t,currentBatch,rawSpikeWaves, m.sRateHz); % compute deviation matrix
	scaleArray=ones(1,length(c.clusters));
	clustersPrev = zeros(length(rawSpikeIdx),1);
end

spikeClusters=zeros(size(rawSpikeWaves,1),1); %reinitialize the spike_clusters
%% determine the template deviation cutoff
if ~isempty(exception) && scaleDir~=0
	scaleArray(~exception)=scaleArray(~exception)+scaleDir*scaling;
elseif isempty(exception) && scaleDir~=0
	scaleArray=scaleArray+scaleDir*scaling; %apply standard reduction for all templates
end
limit = 0.0001;
hitLimit = scaleArray < limit;
scaleArray(hitLimit) = limit; %make sure no scaling factor goes to zero

for ii=1:length(c.clusters)
	devScaled(:,ii)=dMatrix(:,ii)*scaleArray(ii); %scale the deviation matrix
end
[redis,~] = find( devScaled < STDthresh^2);
tempDev = devScaled(redis,:); %gather all the spikes that can be distributed
[~,redisClustNum] = min(tempDev,[],2); %make sure we go for the minimum deviation

for ss=1:size(redis,1) %go through each spike that can be distributed; we don't attempt to update structure c here
	clustName=c.clusters(redisClustNum(ss));
	spikeClusters(redis(ss))=str2double(clustName); %distribute the spike
end

d.clustersPrev = clustersPrev;
d.spikeClusters = spikeClusters;
d.devMatrix = dMatrix;
d.scaleArray = scaleArray;

end