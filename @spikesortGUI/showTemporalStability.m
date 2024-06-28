function [] = showTemporalStability(app, uiPos)
delete(app.Metrics.panelArr(uiPos).Children);
delete(app.Metrics.controlGridArr(uiPos).Children);
app.Metrics.gridArr(uiPos).RowHeight = {22,'1x',0};
app.Metrics.controlGridArr(uiPos).UserData = app.Metrics.dropDownArr(uiPos).Value;

ax = axes('Parent',app.Metrics.panelArr(uiPos));

% plot number of spikes in each unit in each batch
bl = length(app.t.batchLengths);
selection = find(~app.unitArray.tagcmpi("Junk"));

for ii = selection
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
ylabel(ax, "Number of spikes");
legend(ax, "Unit " + string(1:length(app.unitArray)));

end