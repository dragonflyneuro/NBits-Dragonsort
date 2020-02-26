function [devMatrix, templateWavesSet] = getDevMatrix(c, t, templateUnits, templateBatches, orphanWaves, sRate, numTemplates, fuzzyBool)
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

bl = t.batchLengths;
templateWavesSet = cell(1,length(templateUnits));
devMatrix = nan(size(orphanWaves,1),length(templateUnits));

for ii = 1:length(c.clusters)
	if strcmp(c.clusters(ii), templateUnits(ii))
		% generate template from unit
		n = templateUnits(ii);
		unitSpikesInBatchBool = sum(bl(1:templateBatches(1)-1)) < c.("unit_"+n) & c.("unit_"+n) <= sum(bl(1:templateBatches(end)));
		templateWaves = c.("waves_"+n)(unitSpikesInBatchBool,:,:);

		% add waveforms to template from loaded templates if needed
		if isfield(t,("importedTemplateMapping")) && any(strcmp(n, t.importedTemplateMapping{2}(:,1)))...
				&& size(c.("waves_"+n),1) < numTemplates
			templateWaves = [t.("template_"+t.importedTemplateMapping{2}(strcmp(n, t.importedTemplateMapping{2}(:,1)),2)); templateWaves];
		end

		% truncate number of waveforms in template if there are too many
		if size(templateWaves,1)>numTemplates
			r = randperm(size(templateWaves,1));
			templateWaves = templateWaves(r(1:numTemplates),:,:);
		end
	else
		templateWaves = [];
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