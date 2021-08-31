function xi = getFilteredData(app, c)

r = getBatchRange(app,c);
x = double(app.t.yscale*app.fid(:,(r(1)+1):r(2))); % little endian open

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