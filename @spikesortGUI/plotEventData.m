function eventLines = plotEventData(app,h)

yl = ylim(h);
c = app.currentBatch;
bl = app.t.batchLengths;

offset = sum(bl(1:c-1)); % used for converting samples from beginning of file to beginning of batch

if min(size(app.t.importedEventBounds)) == 1
    regionInBatch = offset < app.t.importedEventBounds & app.t.importedEventBounds <= sum(bl(1:c));
    regionInBatch = find(regionInBatch);
    
    for ii = 1:length(regionInBatch)
        regionCoord = (app.t.importedEventBounds(regionInBatch(ii))-offset)*app.msConvert;
        xR = [regionCoord, regionCoord];
        yR = [yl(1), yl(2)];
        eventLines(ii) = plot(ht, xR, yR, 'Color', [0.5,0.5,0.5], 'LineStyle',':','LineWidth',1.5);
    end
else
    regionInBatch = offset < app.t.importedEventBounds(1,:) & app.t.importedEventBounds(1,:) <= sum(bl(1:c));
    regionInBatch = regionInBatch | (offset < app.t.importedEventBounds(2,:) & app.t.importedEventBounds(2,:) <= sum(bl(1:c)));
    regionInBatch = find(regionInBatch);
    
    for ii = 1:length(regionInBatch)
        regionCoord = (app.t.importedEventBounds(:,regionInBatch(ii))-offset)*app.msConvert;
        xR = [regionCoord(1), regionCoord(1), regionCoord(2), regionCoord(2)];
        yR = [yl(1), yl(2), yl(2), yl(1)];
        pgon = polyshape(xR,yR);
        eventLines(ii) = plot(ht, pgon, 'FaceColor','k', 'FaceAlpha',0.3,'LineStyle','none');
    end
end

h.Children = flipud(h.Children);

end
