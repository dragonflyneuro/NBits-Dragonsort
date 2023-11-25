function [] = showTemporalStability(app, selection)
% plot number of spikes in each unit in each batch
bl = length(app.t.batchLengths);

f = figure; ax = axes; set(f, 'Position',  [200, 200, 900, 700]);

for ii=1:selection
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    numInBatch = zeros(1,bl); % number of spikes in each unit in each batch
    for jj = 1:bl
        spikesInBatch = app.unitArray(ii).getAssignedSpikes(getBatchRange(app,[jj-1, jj]));
        numInBatch(jj) = numel(spikesInBatch); % number of spikes in each unit in each batch
    end
    line(ax, 1:bl, numInBatch, 'Color', iiCmap,"Marker",ms);
end

xlabel(ax, "Batch number");
ylabel(ax, "Frequency");
title(ax, 'Spike frequency for each unit over time')
legend(ax, "Unit " + string(1:length(app.unitArray)));

end