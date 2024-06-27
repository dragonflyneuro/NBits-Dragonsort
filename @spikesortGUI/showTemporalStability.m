function [] = showTemporalStability(app, selection)
% plot number of spikes in each unit in each batch
bl = length(app.t.batchLengths);

f = figure; ax = axes; set(f, 'Position',  [300, 200, 800, 700]);

for ii=selection
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    numInBatch = zeros(1,bl); % number of spikes in each unit in each batch
    for jj = 1:bl
        spikesInBatch = app.unitArray(ii).getAssignedSpikes(getBatchRange(app,jj));
        numInBatch(jj) = numel(spikesInBatch); % number of spikes in each unit in each batch
    end
    line(ax, 1:bl, numInBatch, 'Color', iiCmap,"Marker",ms);
end

xlabel(ax, "Batch number (each " + mean(app.t.batchLengths)/app.m.sRateHz + "s long)");
ylabel(ax, "Occurance");
title(ax, 'Number of spikes for each unit over time')
legend(ax, "Unit " + string(1:length(app.unitArray)));

end