function c = forceAdd(c, matchesIdx, matchesWaves, unitNum)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Forces a unit to accept a spike without matching
% 
% INPUT
% c = DragonSort unit-wave structure
% matchesIdx = spike times to add
% matchesWaves = spike waves to add
% unitNum = unit to add spikes to
% 
% fuzzyBool = allows adjustment of threshold based on deviation metric distribution
% 		FORMAT {1, 0}
% OUTPUT
% c = DragonSort unit-wave structure

if ~isempty(matchesIdx)
	if ~isfield(c,"unit_"+unitNum)
		c.clusters(length(c.clusters)+1)=unitNum;
		c.("unit_"+unitNum)= matchesIdx;
		c.("waves_"+unitNum)= matchesWaves;
	else
		c.("unit_"+unitNum)= [c.("unit_"+unitNum) matchesIdx];
		c.("waves_"+unitNum)= [c.("waves_"+unitNum); matchesWaves];
	end
end

end