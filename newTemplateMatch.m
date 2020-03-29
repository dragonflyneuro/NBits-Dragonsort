function [matchesIdx,deviationIdx] = newTemplateMatch(orphanWaves, templateWaves, sRate, thr, fuzzyBool)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Calls template matching function to generate a new unit and updates
% Dragonsort structures
% 
% INPUT
% orphanWaves = waves to match to templateWaves 
%		FORMAT rows: observations, columns: time samples, pages: channels
% templateWaves = waves to match orphanWaves to
%		FORMAT rows: observations, columns: time samples, pages: channels
% sRate = sampling rate
% thr = deviation threshold - waves with deviation below this is added to
%		matchesIdx
% fuzzyBool = allows adjustment of threshold based on deviation metric distribution
% 		FORMAT {1, 0}
% 
% OUTPUT
% matchesIdx = index within elements of orphanWaves that match templateWaves
% deviationIdx = deviation metric of each row of orphanWaves used in matching

% call template matcher
[matchesIdx,~,deviationIdx] = deviationTemplateMatch(orphanWaves,templateWaves,sRate,thr^2,fuzzyBool);
end