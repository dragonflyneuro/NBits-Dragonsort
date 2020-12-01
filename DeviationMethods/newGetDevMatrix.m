function [devMatrix, templateWavesSet] = newGetDevMatrix(uA, t, orphanWaves, range, numTemplates, sRate, fuzzyBool)
% Daniel Ko (dsk13@ic.ac.uk), Huai-Ti Lin [Feb 2020]
% Finds deviation index matrix of orphan waves with respect to a set of
% unit templates.
%
% INPUT
% c = Dragonsort unit-wave structure
% t = Dragonsort unit construction structure
% templateUnits = subset of c.units to make a devMatrix from in string array
% templateBatches = batches from which to take unit templates
% orphanWaves = waves to match to templateWaves
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
devMatrix = nan(size(orphanWaves,1),length(uA));

for ii = 1:length(uA)
    % generate template from unit
    [~,templateWaves,~,~] = uA(ii).getAssignedSpikes(range);

    % add waveforms to template from loaded templates if needed
    if ~isempty(uA(ii).loadedTemplateWaves) && ~isempty(uA(ii).spikeTimes)% < numTemplates
        templateWaves = [uA(ii).loadedTemplateWaves; templateWaves];
    end

    % truncate number of waveforms in template if there are too many
    if size(templateWaves,1)>numTemplates
        r = randperm(size(templateWaves,1));
        templateWaves = templateWaves(r(1:numTemplates),:,:);
    end
	
	% find deviation and normalise
	if ~isempty(templateWaves)
		[~,templateMean,deviation] = deviationTemplateMatch(orphanWaves, templateWaves, sRate, t.add2UnitThr(1)^2, fuzzyBool);
		templateP2p(ii)=max(peak2peak(templateMean,2));
		devMatrix(:,ii)=deviation/templateP2p(ii); %log deviation normalized to template p2p amplitude
	else
		devMatrix(1:size(orphanWaves,1),ii)=inf; %log deviation normalized to template p2p amplitude
	end
	
	% save waveforms used to make templates
	templateWavesSet{ii} = templateWaves;
end

devMatrix = devMatrix.*median(templateP2p(templateP2p ~= 0)); %complete the deviation p2p correction

end