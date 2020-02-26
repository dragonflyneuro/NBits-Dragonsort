function thr = autoThreshold(thr, devIdx)

u = lowpass(histcounts(devIdx,'BinWidth',2),0.5);
udot = diff(u);
crossover = find(diff(udot > 0.5) == 1);
if ~isempty(crossover)
	crossover = crossover*2;
	[A, I] = min(abs(thr - crossover));
	if abs(thr-A) < thr
		thr = crossover(I);
	end
end
end