function [assignedUnit, potentialSpikes] = autoCreateUnits(orphanWaves, y, thr, sRate, cutoff, k, direction, fuzzyBool, cropFactor, sampleW)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Calls template matching function for to generate a new unit and updates
% Dragonsort structures
%
% INPUT
% c = Dragonsort unit-wave structure
% t = Dragonsort unit construction structure
% orphanWaves = waves to try and create units from
%		FORMAT rows: observations, columns: time samples, pages: channels
% y = amplitudes of peaks of each observation of orphanWaves
% sRate = sampling rate
% orphansInBatch = index of spikes in the batch that was used to create
%		orphanWaves
% orphanSpikes = spike indexes of orphanWaves
% cutoff = amplitude cutoff for orphanWaves to create units from
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

orphanWaves = orphanWaves(potentialSpikes,:,:);
croppedWaves = orphanWaves(:,ceil(size(orphanWaves,2)/2) + (round(-0.3*sRate/1000):round(0.3*sRate/1000)),:);
croppedWaves = reshape(croppedWaves, size(orphanWaves,1), []);

PC = pca(croppedWaves);
PCwaves = croppedWaves*PC(:,1:3);
clust = kmeans(PCwaves',k);
uniqueClust = unique(clust);
potentialSpikes = find(potentialSpikes);

%%
devIdx = inf(length(uniqueClust),size(orphanWaves,1));
for ii = 1:length(uniqueClust)
    templateWaves = orphanWaves(clust == uniqueClust(ii),:,:);
    if size(templateWaves,1) > 30
        [~,~,devIdx(d,:)] = deviationTemplateMatch(orphanWaves, templateWaves, sRate, thr, 0, cropFactor, sampleW);
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