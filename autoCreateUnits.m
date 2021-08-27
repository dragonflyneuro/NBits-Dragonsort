function [assignedUnit, potentialSpikes] = autoCreateUnits(unassignedWaves, y, thr, sRate, cutoff, k, direction, fuzzyBool, cropFactor, sampleW)
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
d = 1;
assignedUnit = [];
    
if direction == 1
    potentialSpikes = y > cutoff;
    percentLimit = 0.2;
else
    potentialSpikes = y < cutoff;
    percentLimit = 0;
end

if nnz(potentialSpikes) <= length(potentialSpikes)*percentLimit
    return;
end

unassignedWaves = unassignedWaves(potentialSpikes,:,:);
croppedWaves = unassignedWaves(:,ceil(size(unassignedWaves,2)/2) + (round(-0.3*sRate/1000):round(0.3*sRate/1000)),:);
croppedWaves = croppedWaves(:,:);

PC = pca(croppedWaves);
PCwaves = croppedWaves*PC(:,1:3);
clust = kmeans(PCwaves',k);
uniqueClust = unique(clust);
potentialSpikes = find(potentialSpikes);

%%
devIdx = inf(length(uniqueClust),size(unassignedWaves,1));
for ii = 1:length(uniqueClust)
    templateWaves = unassignedWaves(clust == uniqueClust(ii),:,:);
    if size(templateWaves,1) > 30
        [~,~,devIdx(d,:)] = deviationTemplateMatch(unassignedWaves, templateWaves, sRate, thr, 0, cropFactor, sampleW);
        d = d+1;
    end
end
if ~all(isinf(devIdx))
    [devMins, devMinIdx] = min(devIdx,[],1);
    assigned = devMins < thr^2;
    assignedUnit = assigned.*devMinIdx;
end
%% simpler method - no checking
% for ii = 1:length(uniqueClust)
%     numAssigned = sum(clust == uniqueClust(ii));
%     if numAssigned < 30
%         clust(clust == uniqueClust(ii)) = 0;
%     end
% end
% assignedUnit = clust;

%%


end