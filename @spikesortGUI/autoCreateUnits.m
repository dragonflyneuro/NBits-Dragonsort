function [c, t, numNewUnits] = autoCreateUnits(c, t, orphanWaves, y, sRate, orphansInBatch, orphanSpikes, cutoff, direction, fuzzyBool)
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

numNewUnits = 0;
if direction == 1
    potentialSpikes = y > cutoff;
    percentLimit = 0.2;
else
    potentialSpikes = y < cutoff;
    percentLimit = 0;
end
if nnz(potentialSpikes) > length(potentialSpikes)*percentLimit
    orphanWaves = orphanWaves(potentialSpikes,:,:);
    orphanSpikes = orphanSpikes(potentialSpikes);
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
            [~,devIdx(ii,:)] = newTemplateMatch(orphanWaves, templateWaves, sRate, t.add2UnitThr(2), fuzzyBool);
        end
    end
    if ~all(isinf(devIdx))
        [devMins, devMinIdx] = min(devIdx,[],1);
        assigned = devMins < (t.add2UnitThr(2)*6)^2;
        assignedUnit = assigned.*devMinIdx;
        unitAssigned = unique(assignedUnit);
        unitAssigned(unitAssigned == 0) = [];
        if nnz(assignedUnit) ~= 0
            for ii = unitAssigned
                c.clusters(end+1)=string(max(str2double(c.clusters))+1);
                c.("unit_"+c.clusters(end)) = orphanSpikes(assignedUnit == ii);
                c.("waves_"+c.clusters(end)) = orphanWaves(assignedUnit == ii,:,:);
                
                t.orphanBool(orphansInBatch(assignedUnit == ii)) = 0;
                t.spikeClust(orphansInBatch(assignedUnit == ii)) = str2double(c.clusters(end));
                
                numNewUnits = numNewUnits + 1;
            end
        end
    end
end

end