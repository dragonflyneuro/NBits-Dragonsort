function thr = autoThreshold(thr, metric)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Adjusts metric's threshold by histogram analysis to find population
% breakpoints
% 
% INPUT
% thr = initial threshold
% metric = metrics found for a dataset
% 
% OUTPUT
% thr = adjusted threshold

u = lowpass(histcounts(metric,'BinWidth',2),0.5); % find histogram of data metrics
udot = diff(u); % find slope of histogram at each bin
risingSlope = find(diff(udot > 0.5) == 1); % find rising slopes
if ~isempty(risingSlope)
	risingSlope = risingSlope*2;
	[A, I] = min(abs(thr - risingSlope)); % find closest rising slope to initial threshold
	if abs(thr-A) < thr % do not allow threshold to change by too much
		thr = risingSlope(I);
	end
end

end