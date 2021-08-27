function [devMatrix, templateWavesSet, thr] = getDevMatrix(thr, uA, unassignedWaves, range, numTemplates, sRate, fuzzyBool, cropFactor, sampleW)
% Daniel Ko (dsk13@ic.ac.uk), Huai-Ti Lin [Feb 2020]
% Finds deviation index matrix of orphan waves with respect to a set of
% unit templates.
%
% INPUT
% c = Dragonsort unit-wave structure
% t = Dragonsort unit construction structure
% templateUnits = subset of c.units to make a devMatrix from in string array
% templateBatches = batches from which to take unit templates
% unassignedWaves = waves to match to templateWaves
%		FORMAT rows: observations, columns: time samples, pages: channels
% sRate = sampling rate
% numTemplates = number of waves to form a template with from each unit
% fuzzyBool = allows adjustment of threshold based on deviation metric distribution
% 		FORMAT {1, 0}
%
% OUTPUT
% devMatrix = matrix of deviation of each orphan spike to each unit
%		FORMAT rows: orphan spike observations, columns: deviation index to
%		each unit template
% templateWavsSet = cell of template waveforms used for each unit

templateWavesSet = cell(1,length(uA));
devMatrix = nan(size(unassignedWaves,1),length(uA));

templateP2p = zeros(1,length(uA));
thr = ones(1,length(uA))*thr^2;

for ii = 1:length(uA)
    % generate template from unit
    [~,templateWaves,~] = uA(ii).getAssignedSpikes(range);
    
    % add waveforms to template from loaded templates if needed
    if ~isempty(uA(ii).loadedTemplateWaves) && isempty(uA(ii).spikeTimes)% < numTemplates
        templateWaves = [uA(ii).loadedTemplateWaves; templateWaves];
    end
    
    % truncate number of waveforms in template if there are too many
    if size(templateWaves,1)>numTemplates
        r = randperm(size(templateWaves,1));
        templateWaves = templateWaves(r(1:numTemplates),:,:);
    end
    
    % find deviation and normalise
    if ~isempty(templateWaves)
        [~,templateMean,deviation] = deviationTemplateMatch(unassignedWaves, templateWaves, sRate, thr(ii), 0, cropFactor, sampleW);
        templateP2p(ii) = max(peak2peak(templateMean,2));
        devMatrix(:,ii) = deviation/templateP2p(ii); %log deviation normalized to template p2p amplitude
    else
        devMatrix(1:size(unassignedWaves,1),ii)=inf;
    end
    
    % save waveforms used to make templates
    templateWavesSet{ii} = templateWaves;
end

devMatrix = devMatrix.*median(templateP2p(templateP2p ~= 0)); %complete the deviation p2p correction
for ii = 1:length(uA)
    if templateP2p(ii) > 0
        if fuzzyBool
            thr(ii) = autoThreshold(thr(ii)*median(templateP2p(templateP2p ~= 0))/templateP2p(ii),devMatrix(:,ii));
        else
            thr(ii) = thr(ii)/templateP2p(ii);
        end
    end
end

end