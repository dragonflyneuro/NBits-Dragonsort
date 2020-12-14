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
binSize = min([0.03, peak2peak(metric)/20]);
[h, bE] = histcounts(metric,'BinWidth',binSize);
% histogram(metric,'BinWidth',binSize);
bC = bE(1:end-1)+binSize/2;
[~,peaks] = findpeaks(-h,'Threshold',length(metric)/500);
if ~isempty(peaks)
	[A, I] = min(abs(thr - bC(peaks))); % find closest rising slope to initial threshold
	if abs(thr-A) < thr % do not allow threshold to change by too much
		thr = bC(peaks(I));
	end
end

end