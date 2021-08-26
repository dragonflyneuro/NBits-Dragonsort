function updateView(~, ~, h, scatterData, u, sel, axisChoice, sizeSldr)
[caz,cel] = view(h);
cla(h)

for ii = 1:length(axisChoice)
    choice(ii) = find(strcmp(axisChoice(ii).Value,axisChoice(ii).Items),1,'first');
end
xlabel(h,axisChoice(1).Value); ylabel(h,axisChoice(2).Value);
if choice(3) ~= length(axisChoice(3).Items)
    zlabel(h,axisChoice(3).Value);
end

for ii=1:length(sel)
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    if ~isempty(u(sel(ii)).waves)
        if choice(3) ~= length(axisChoice(3).Items)
            scatter3(h, scatterData{ii}(:,choice(1)),scatterData{ii}(:,choice(2)),scatterData{ii}(:,choice(3)),sizeSldr.Value,...
                repmat(iiCmap,size(scatterData{ii},1),1),"Marker",ms);
            if caz == 0 && cel == 90
                view(h,[-5 2 5]);
            end
        else
            scatter(h, scatterData{ii}(:,choice(1)),scatterData{ii}(:,choice(2)),sizeSldr.Value,...
                repmat(iiCmap,size(scatterData{ii},1),1),"Marker",ms);
            view(h,2);
        end
    end
end

end