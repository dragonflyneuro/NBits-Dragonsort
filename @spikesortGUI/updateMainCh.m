function [] = updateMainCh(app)
bl = app.t.batchLengths;
app.t.rawSpikeSample = [];

for ii = 1:length(bl)
    xi = getFilteredData(app, ii);
    r = getBatchRange(app,ii);
    
    [~, sTimesOffset] = spike_times2(xi(app.m.mainCh, 1:end-app.m.spikeWidth), app.t.detectThr(2), -1); % aligned to negative peak
    sTimesOffset = sTimesOffset(sTimesOffset > app.m.spikeWidth+1);
    sTimesOffset(xi(app.m.mainCh,sTimesOffset) < app.t.detectThr(1)) = [];
    sTimesReal = sTimesOffset + r(1);
    
    if ~isempty(app.t.noSpikeRange)
        for jj = 1:size(app.t.noSpikeRange,2)
            sTimesReal(sTimesReal >= app.t.noSpikeRange(1,jj) & sTimesReal <= app.t.noSpikeRange(2,jj)) = [];
        end
    end
    
    app.t.rawSpikeSample = [app.t.rawSpikeSample, sTimesReal];
    
    spike = cell(length(app.unitArray),1);
    wave = cell(length(app.unitArray),1);
    
    for jj = 1:length(app.unitArray)
        [sTimes, ~, spikesInBatch] = app.unitArray(jj).getAssignedSpikes(r);
        app.unitArray = app.unitArray.spikeRemover(jj,spikesInBatch,1);
        
        for kk = 1:length(sTimes)
            [valMin, idxMin] = min(abs(sTimes(kk)-sTimesReal));
            if valMin < 3
                wave{jj} = cat(3,wave{jj},xi(:, sTimesOffset(kk)+(-app.m.spikeWidth:app.m.spikeWidth)));
                spike{jj} = [spike{jj}, sTimesReal(idxMin)];
            end
        end
    end
    for jj = 1:length(app.unitArray)
        for kk = jj+1:length(app.unitArray)
            [~, idxCom] = intersect(spike{kk},spike{jj});
            spike{kk}(idxCom) = [];
            wave{kk}(:,:,idxCom) = [];
        end
        if ~isempty(spike{jj})
            app.unitArray = app.unitArray.refinedSpikeAdder(jj,spike{jj},permute(wave{jj},[3 2 1]));
        end
    end
    
end