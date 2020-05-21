function [] = readFilter(app, offset, traceMove)

%   read a batch of data of length t.batchLengths samples and filter it.
%   Extract spike times also
app.StatusLabel.Value = "Reading data...";
drawnow
fseek(app.fid,offset,'cof');
app.currentBatch = app.currentBatch + traceMove;
c = app.currentBatch;
bl = app.t.batchLengths;

x = app.t.yscale*fread(app.fid,[app.m.nChans, bl(c)], 'int16','l'); % little endian open
app.m.el_f = fir1(app.m.el_flen,[app.m.el_cutH app.m.el_cutL]./(app.m.sRateHz/2));
d = 1;
app.xi = [];
for ii=app.m.ech % filter each electrode channel in turns
    app.xi(d,:) = splitconv(x(ii,:),app.m.el_f);
    d = d+1;
end
yOffset = prctile(app.xi,50,2); %yoffset = mean(xi,2);
app.xi = app.xi - yOffset(1:size(app.xi,1),:); % remove DC offset

filtSTD=std(app.xi,0,2); %StD of the signal in real unit (mV)
filtRMS=rms(app.xi,2);
fprintf('Filtered Data [%i/%i]: \t STD: %.4f, \t RMS: %.4f \n', c, length(bl), filtSTD,filtRMS);

[~, detectedSpikes] = spike_times2(app.xi(app.m.mainCh, 1:end-app.m.spikeWidth), app.t.detectThr(2), -1); % aligned to negative peak
detectedSpikes = detectedSpikes(detectedSpikes > app.m.spikeWidth+1);
detectedSpikes(app.xi(app.m.mainCh,detectedSpikes) < app.t.detectThr(1)) = [];
offsetSpikes = detectedSpikes + sum(bl(1:c-1));
if ~isempty(app.t.noSpikeRange)
    for ii = 1:size(app.t.noSpikeRange,2)
        offsetSpikes(offsetSpikes >= app.t.noSpikeRange(1,ii) & offsetSpikes <= app.t.noSpikeRange(2,ii)) = [];
    end
end

oldSpikeRange = [sum(app.t.numSpikesInBatch(1:c-1))+1, sum(app.t.numSpikesInBatch(1:c))];
if length(offsetSpikes) ~= diff(oldSpikeRange)+1
    app.t.numSpikesInBatch(c) = length(offsetSpikes);
    newSpikeClust = zeros(size(offsetSpikes));
    if diff(oldSpikeRange)+1 ~= 0
        for ii = app.s.clusters
            newSpikeClust = newSpikeClust + str2double(ii)*ismember(offsetSpikes, app.s.("unit_"+ii));
            unitSpikesInBatchBool = sum(bl(1:c-1)) < app.s.("unit_"+ii) & app.s.("unit_"+ii) <= sum(bl(1:c));
            deletedSpikes = unitSpikesInBatchBool & ~ismember(app.s.("unit_"+ii), offsetSpikes);
            app.s.("unit_"+ii)(deletedSpikes) = [];
            app.s.("waves_"+ii)(deletedSpikes,:) = [];
        end
    end
    app.t.spikeClust = insertLongArrays(app.t.spikeClust, newSpikeClust, oldSpikeRange);
    app.t.orphanBool = insertLongArrays(app.t.orphanBool, ~logical(newSpikeClust), oldSpikeRange);
    app.t.rawSpikeSample = insertLongArrays(app.t.rawSpikeSample, offsetSpikes, oldSpikeRange);
end

app.rawSpikeWaves = [];
for ii=1:length(detectedSpikes)
    tempWave=app.xi(1:end, detectedSpikes(ii)-app.m.spikeWidth:detectedSpikes(ii)+app.m.spikeWidth);
    app.rawSpikeWaves=cat(1,app.rawSpikeWaves, permute(tempWave, [3 2 1])); % accumulate a wave
end

app.StatusLabel.Value = "Ready";

end