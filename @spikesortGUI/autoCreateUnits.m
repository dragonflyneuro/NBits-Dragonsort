function assignedUnit = autoCreateUnits(orphanWaves, y, thr, sRate, cutoff, direction, fuzzyBool)
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

if direction == 1
    potentialSpikes = y > cutoff;
    percentLimit = 0.2;
else
    potentialSpikes = y < cutoff;
    percentLimit = 0;
end

if nnz(potentialSpikes) > length(potentialSpikes)*percentLimit
    orphanWaves = orphanWaves(potentialSpikes,:,:);
    croppedWaves = orphanWaves(:,ceil(size(orphanWaves,2)/2) + (round(-0.3*sRate/1000):round(0.3*sRate/1000)),:);
    croppedWaves = reshape(croppedWaves, size(orphanWaves,1), []);
    
    PC = pca(croppedWaves);
    PCwaves = croppedWaves*PC(:,1:3);
    clust = kmeans_opt(PCwaves,5);
    uniqueClust = unique(clust);
    
    devIdx = inf(length(uniqueClust),size(orphanWaves,1));
    for ii = 1:length(uniqueClust)
        templateWaves = orphanWaves(clust == uniqueClust(ii),:,:);
        if size(templateWaves,1) > 10
            [~,~,devIdx(ii,:)] = deviationTemplateMatch(orphanWaves, templateWaves, sRate, thr, fuzzyBool);
        end
    end
    if ~all(isinf(devIdx))
        [devMins, devMinIdx] = min(devIdx,[],1);
        assigned = devMins < thr^2;
        assignedUnit = assigned.*devMinIdx;
    end
end

end