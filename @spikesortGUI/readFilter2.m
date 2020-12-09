function [] = readFilter2(app, batchNum)
%   read a batch of data of length t.batchLengths samples and filter it.
%   Extract spike times also
app.StatusLabel.Value = "Reading data...";
drawnow
app.currentBatch = batchNum;
c = app.currentBatch;
bl = app.t.batchLengths;

x = double(app.t.yscale*app.fid(:,sum(bl(1:c-1))+1:sum(bl(1:c)))); % little endian open
if strcmpi(app.m.filterSpec.firstBandMode, 'stop')
    filterVec = fir1(app.m.filterSpec.order,...
        app.m.filterSpec.cutoffs./(app.m.sRateHz/2),'DC-0');
else
    filterVec = fir1(app.m.filterSpec.order,...
        app.m.filterSpec.cutoffs./(app.m.sRateHz/2),'DC-1');
end

app.xi = splitconv(x(app.m.ech,:),filterVec);
yOffset = prctile(app.xi,50,2); %yoffset = mean(xi,2);
app.xi = app.xi - yOffset(1:size(app.xi,1),:); % remove DC offset

[~, detectedSpikes] = spike_times2(app.xi(app.m.mainCh, 1:end-app.m.spikeWidth), app.t.detectThr(2), -1); % aligned to negative peak
detectedSpikes = detectedSpikes(detectedSpikes > app.m.spikeWidth+1);
detectedSpikes(app.xi(app.m.mainCh,detectedSpikes) < app.t.detectThr(1)) = [];
offsetSpikes = detectedSpikes + sum(bl(1:c-1));
if ~isempty(app.t.noSpikeRange)
    for ii = 1:size(app.t.noSpikeRange,2)
        offsetSpikes(offsetSpikes >= app.t.noSpikeRange(1,ii) & offsetSpikes <= app.t.noSpikeRange(2,ii)) = [];
    end
end

r = getBatchRange(app);
oldSpikeBool = r(1) < app.t.rawSpikeSample & app.t.rawSpikeSample <= r(2);
if length(offsetSpikes) ~= sum(oldSpikeBool)
    if isempty(app.t.rawSpikeSample) || r(2) < app.t.rawSpikeSample(1)
        app.t.rawSpikeSample = [offsetSpikes, app.t.rawSpikeSample];
    elseif r(1) > app.t.rawSpikeSample(end)
        app.t.rawSpikeSample = [app.t.rawSpikeSample, offsetSpikes];
    else
        if sum(oldSpikeBool) ~= 0
            for ii = 1:length(app.unitArray)
                [sTimes, ~, unitIdx] = app.unitArray(ii).getAssignedSpikes(getBatchRange(app));
                deletedSpikes =  ~ismember(sTimes, offsetSpikes);
                app.unitArray = app.unitArray.spikeRemover(ii,unitIdx(deletedSpikes));
            end
        end
        app.t.rawSpikeSample = [app.t.rawSpikeSample(1:find(oldSpikeBool,1,'first')-1), offsetSpikes, ...
            app.t.rawSpikeSample(find(oldSpikeBool,1,'last')+1:end)];
    end
end

newWaves = zeros(size(app.xi,1),app.m.spikeWidth*2+1,length(detectedSpikes));
for ii=1:length(detectedSpikes)
    newWaves(:,:,ii) = app.xi(:, detectedSpikes(ii)+(-app.m.spikeWidth:app.m.spikeWidth));
end
app.rawSpikeWaves = permute(newWaves, [3 2 1]);

app.StatusLabel.Value = "Ready";

end