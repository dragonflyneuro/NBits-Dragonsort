function xi = getFilteredData(app, c)

bl = app.t.batchLengths;

if c ~= 1
    x = double(app.t.yscale*app.fid(:,(sum(bl(1:c-1))+1-app.m.spikeWidth):sum(bl(1:c)))); % little endian open
else
    x = double(app.t.yscale*app.fid(:,1:bl(1))); % little endian open
end

if strcmpi(app.m.filterSpec.firstBandMode, 'stop')
    filterVec = fir1(app.m.filterSpec.order,...
        app.m.filterSpec.cutoffs./(app.m.sRateHz/2),'DC-0');
else
    filterVec = fir1(app.m.filterSpec.order,...
        app.m.filterSpec.cutoffs./(app.m.sRateHz/2),'DC-1');
end

xi = zeros(size(x));
for ii = 1:length(app.m.ech)
    xi(ii,:) = splitconv(x(app.m.ech(ii),:),filterVec);
end
yOffset = prctile(xi,50,2); %yoffset = mean(xi,2);
xi = xi - yOffset(1:size(xi,1),:); % remove DC offset

end