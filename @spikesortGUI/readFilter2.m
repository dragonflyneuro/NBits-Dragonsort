function [] = readFilter2(app, batchNum)
%   read a batch of data of length t.batchLengths samples and filter it.
%   Extract spike times also
app.StatusLabel.Value = "Reading data...";
drawnow
app.currentBatch = batchNum;
c = app.currentBatch;
bl = app.t.batchLengths;

app.xi = getFilteredData(app, c);

[~, sTimesOffset] = spike_times2(app.xi(app.m.mainCh, 1:end-app.m.spikeWidth), app.t.detectThr(2), -1); % aligned to negative peak
sTimesOffset = sTimesOffset(sTimesOffset > app.m.spikeWidth+1);
sTimesOffset(app.xi(app.m.mainCh,sTimesOffset) < app.t.detectThr(1)) = [];
if c ~= 1
    sTimesReal = sTimesOffset + sum(bl(1:c-1)) - app.m.spikeWidth;
else
    sTimesReal = sTimesOffset;
end

if ~isempty(app.t.noSpikeRange)
    for ii = 1:size(app.t.noSpikeRange,2)
        sTimesReal(sTimesReal >= app.t.noSpikeRange(1,ii) & sTimesReal <= app.t.noSpikeRange(2,ii)) = [];
    end
end

r = getBatchRange(app);
oldSpikeBool = r(1) < app.t.rawSpikeSample & app.t.rawSpikeSample <= r(2);
if length(sTimesReal) ~= sum(oldSpikeBool)
    if isempty(app.t.rawSpikeSample) || r(2) < app.t.rawSpikeSample(1)
        app.t.rawSpikeSample = [sTimesReal, app.t.rawSpikeSample];
    elseif r(1) > app.t.rawSpikeSample(end)
        app.t.rawSpikeSample = [app.t.rawSpikeSample, sTimesReal];
    else
        if sum(oldSpikeBool) ~= 0
            for ii = 1:length(app.unitArray)
                [sTimes, ~, unitIdx] = app.unitArray(ii).getAssignedSpikes(getBatchRange(app));
                deletedSpikes =  ~ismember(sTimes, sTimesReal);
                app.unitArray = app.unitArray.spikeRemover(ii,unitIdx(deletedSpikes));
            end
        end
        app.t.rawSpikeSample = [app.t.rawSpikeSample(1:find(oldSpikeBool,1,'first')-1), sTimesReal, ...
            app.t.rawSpikeSample(find(oldSpikeBool,1,'last')+1:end)];
    end
end

newWaves = zeros(size(app.xi,1),app.m.spikeWidth*2+1,length(sTimesOffset));
for ii=1:length(sTimesOffset)
    newWaves(:,:,ii) = app.xi(:, sTimesOffset(ii)+(-app.m.spikeWidth:app.m.spikeWidth));
end
app.rawSpikeWaves = permute(newWaves, [3 2 1]);

app.StatusLabel.Value = "Ready";

end