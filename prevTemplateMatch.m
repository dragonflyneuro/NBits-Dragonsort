function [c, assignedUnit] = prevTemplateMatch(c, t, orphanSpikes, orphanWaves, templateBatches, sRate, thr, numTemplates, fuzzyBool)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Calls template matching function to add spikes to existing Dragonsort units
% and updates Dragonsort structures
% 
% INPUT
% c = Dragonsort unit-wave structure
% t = Dragonsort unit construction structure
% orphanSpikes = spike indexes of orphanWaves
% orphanWaves = waves to match to templateWaves 
%		FORMAT rows: observations, columns: time samples, pages: channels
% templateBatches = batches from which to take unit templates
% sRate = sampling rate
% thr = deviation threshold - waves with deviation below this is assigned
%		to a unit
% numTemplates = number of waves to form a template with from each unit
% fuzzyBool = allows adjustment of threshold based on deviation metric distribution
% 		FORMAT {1, 0}
% 
% OUTPUT
% c = Dragonsort unit-wave structure
% assignedUnit = new spike-unit assignments

% call template matcher and get new spike-unit assignments
[devMatrix, ~] = getDevMatrix(c, t, c.clusters, templateBatches, orphanWaves, sRate, numTemplates, fuzzyBool);
[devMins, devMinIdx] = min(devMatrix,[],1);
assigned = devMins < thr^2;
assignedUnit = assigned.*devMinIdx;

% update Dragonsort structures
for ii = 1:length(c.clusters)
	unitNum = c.clusters(ii);
	oneUnit = assignedUnit == ii;
	if nnz(oneUnit) > 0
		c.("unit_"+unitNum)=[c.("unit_"+unitNum), orphanSpikes(oneUnit)]; %appending to exisiting
		c.("waves_"+unitNum)=[c.("waves_"+unitNum); orphanWaves(oneUnit,:,:)];
		[c.("unit_"+unitNum), I, ~] = unique(c.("unit_"+unitNum));
		c.("waves_"+unitNum) = c.("waves_"+unitNum)(I,:,:);
	end
end

end