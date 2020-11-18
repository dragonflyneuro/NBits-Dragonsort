function [] = readFilter2(app, traceMove)
%   read a batch of data of length t.batchLengths samples and filter it.
%   Extract spike times also
app.StatusLabel.Value = "Reading data...";
drawnow
app.currentBatch = app.currentBatch + traceMove;
c = app.currentBatch;
bl = app.t.batchLengths;

x = double(app.t.yscale*app.fid(:,sum(bl(1:c-1))+1:sum(bl(1:c)))); % little endian open
app.m.el_f = fir1(app.m.el_flen,[app.m.el_cutH app.m.el_cutL]./(app.m.sRateHz/2));
d = 1;
app.xi = [];
for ii=app.m.ech % filter each electrode channel in turns
    app.xi(d,:) = splitconv(x(ii,:),app.m.el_f);
    d = d+1;
end
yOffset = prctile(app.xi,50,2); %yoffset = mean(xi,2);
app.xi = app.xi - yOffset(1:size(app.xi,1),:); % remove DC offset

% filtSTD=std(app.xi,0,2); %StD of the signal in real unit (mV)
% filtRMS=rms(app.xi,2);
% fprintf('Filtered Data [%i/%i]: \t STD: %.4f, \t RMS: %.4f \n', c, length(bl), filtSTD,filtRMS);

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
    if diff(oldSpikeRange)+1 ~= 0
        for ii = 1:length(app.unitArray)
            unitSpikesInBatchBool = sum(bl(1:c-1)) < app.unitArray(ii).spikeTimes &...
                app.unitArray(ii).spikeTimes <= sum(bl(1:c));
            deletedSpikes = unitSpikesInBatchBool & ~ismember(app.unitArray(ii).spikeTimes, offsetSpikes);
            app.unitArray = app.unitArray.spikeRemover(ii,deletedSpikes);
        end
    end
    app.t.rawSpikeSample = insertLongArrays(app.t.rawSpikeSample, offsetSpikes, oldSpikeRange);
end

app.rawSpikeWaves = [];
for ii=1:length(detectedSpikes)
    tempWave=app.xi(:, detectedSpikes(ii)-app.m.spikeWidth:detectedSpikes(ii)+app.m.spikeWidth);
    app.rawSpikeWaves=cat(1,app.rawSpikeWaves, permute(tempWave, [3 2 1])); % accumulate a wave
end

app.StatusLabel.Value = "Ready";

end

function out = insertLongArrays(A, B, insertLoc)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% 
% INPUT
% A = array to insert into
% B = array to insert
% insertLoc = range of indices in A to replace and insert B into
%		FORMAT [insert location start, insert location end]
% 
% OUTPUT
% out = new combined array

out = [A(1:insertLoc(1)-1), B, A(insertLoc(2)+1:end)];

end