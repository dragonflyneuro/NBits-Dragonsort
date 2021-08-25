function [] = updateSpikeWidth(app)

bl = app.t.batchLengths;

newWaves = cell(length(app.unitArray),1);

for ii = 1:length(bl)
    xi = getFilteredData(app,ii);
    if ii == app.currentBatch
        app.xi = xi;
    end
    
    for jj = 1:length(app.unitArray)
        [sTimes, ~, ~] = app.unitArray(jj).getAssignedSpikes(getBatchRange(app,[ii,ii]));
        
        if ~isempty(sTimes)
            if ii ~= 1
                sTimesOffset = sTimes - sum(bl(1:ii-1)) + app.m.spikeWidth;
            else
                sTimesOffset = sTimes;
            end

            for kk=1:length(sTimes)
                newWaves{jj}(:,:,end+1) = xi(:, sTimesOffset(kk)+(-app.m.spikeWidth:app.m.spikeWidth));
            end
        end
    end
end

for ii = 1:length(app.unitArray)
    app.unitArray(ii).waves = permute(newWaves{ii}, [3 2 1]);
end
end