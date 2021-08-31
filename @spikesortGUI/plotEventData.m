function eventLines = plotEventData(app,h)

yl = ylim(h);

r = getBatchRange(app); % used for converting samples from beginning of file to beginning of batch

if min(size(app.t.importedEventBounds)) == 1
    regionInBatch = r(1) < app.t.importedEventBounds & app.t.importedEventBounds <= r(2);
    regionInBatch = find(regionInBatch);
    
    for ii = 1:length(regionInBatch)
        regionCoord = (app.t.importedEventBounds(regionInBatch(ii))-r(1))*app.msConvert;
        xR = [regionCoord, regionCoord];
        yR = [yl(1), yl(2)];
        eventLines(ii) = plot(ht, xR, yR, 'Color', [0.5,0.5,0.5], 'LineStyle',':','LineWidth',1.5);
    end
else
    regionInBatch = r(1) < app.t.importedEventBounds(1,:) & app.t.importedEventBounds(1,:) <= r(2);
    regionInBatch = regionInBatch | (r(1) < app.t.importedEventBounds(2,:) & app.t.importedEventBounds(2,:) <= r(2));
    regionInBatch = find(regionInBatch);
    
    for ii = 1:length(regionInBatch)
        regionCoord = (app.t.importedEventBounds(:,regionInBatch(ii))-r(1))*app.msConvert;
        xR = [regionCoord(1), regionCoord(1), regionCoord(2), regionCoord(2)];
        yR = [yl(1), yl(2), yl(2), yl(1)];
        pgon = polyshape(xR,yR);
        eventLines(ii) = plot(ht, pgon, 'FaceColor','k', 'FaceAlpha',0.3,'LineStyle','none');
    end
end

h.Children = flipud(h.Children);

end
