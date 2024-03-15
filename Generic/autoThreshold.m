function thr = autoThreshold(thr, metric, binSize)
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
[h, bE] = histcounts(metric,'BinWidth',binSize);
% histogram(metric,'BinWidth',binSize);
bC = bE(1:end-1)+binSize/2;
[~,peaks] = findpeaks(movmean(-h,5));
if ~isempty(peaks)
	[~, I] = min(abs(thr - bC(peaks))); % find closest rising slope to initial threshold
    troughThr = bC(peaks(I));
	if abs(thr-troughThr) < abs(0.1*thr) % do not allow threshold to change by too much
		thr = troughThr;
	end
end

end