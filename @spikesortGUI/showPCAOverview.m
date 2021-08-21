function [] = showPCAOverview(app, u, selection)

if ~isrow(selection)
    selection = selection';
end

allClust = [];
for ii = selection
    waves = u(selection).waves(:,:,u(selection).mainCh);
    if ~isempty(waves)
        allClust = cat(1,allClust, waves);
    end
end

PC = pca(allClust);

figure; set(gcf, 'Position',  [1100, 200, 700, 600]);

for ii=1:length(selection)
    iiCmap=app.cmap(rem(ii-1,25)+1,:);
    ms = getMarker(size(app.cmap,1), ii);
    title(ax(ii), 'Unit '+string(selection(ii))+" "+...
        ms +" ("+length(u(selection(ii)).spikeTimes)+")",'Color',iiCmap);
    if ~isempty(u(selection(ii)).waves)
        clusPC = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh)*PC(:,1:3);
        scatter3(clusPC(:,1),clusPC(:,2),clusPC(:,3),20,repmat(iiCmap,size(clusPC,1),1),"Marker",ms); % 3D PCA plot
    end
    hold on;
end
xlabel("PC1"); ylabel("PC2"); zlabel("PC3");
title('Units found - PCs view');
legend("Unit " + selection);

end