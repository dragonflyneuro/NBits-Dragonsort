function txt = getUnitTitle(app, uIdx)

c = app.currentBatch;

if ~isempty(app.unitArray(uIdx).spikeTimes) % if there are spikes in the unit

    last3Batches = [0,0,0];
    for jj = 0:2
        if c-jj > 0
            last3Batches(jj+1) = nnz(app.unitArray(uIdx).getAssignedSpikes(getBatchRange(app,c-jj)));
        end
    end

    if ~isempty(app.unitArray(uIdx).name)
        nameText = """"+app.unitArray(uIdx).name+""" ";
    else
        nameText = "";
    end

    if strcmpi("Junk",app.unitArray(uIdx).tags)
        junkText = " JUNK";
    else
        junkText = "";
    end

    if ismissing(string(app.unitArray(uIdx).meanDeviation))
        txt = nameText + string(length(app.unitArray(uIdx).spikeTimes)) +...
            " spikes, last 3 batches " + last3Batches(3) + "/" + last3Batches(2) +...
            "/" + last3Batches(1) + junkText;
    else
        txt = nameText + string(length(app.unitArray(uIdx).spikeTimes)) +...
            " spikes, last 3 batches " + last3Batches(3) + "/" + last3Batches(2) +...
            "/" + last3Batches(1) + ", meanDev " + string(app.unitArray(uIdx).meanDeviation) + junkText;
    end

elseif ~isempty(app.unitArray(uIdx).loadedTemplateWaves)
    txt = "TEMPLATE SPIKES ONLY";

else
    txt = "No spikes!";

end

end