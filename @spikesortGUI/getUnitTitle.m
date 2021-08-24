function txt = getUnitTitle(app, unitNum)

c = app.currentBatch;

if ~isempty(app.unitArray(unitNum).spikeTimes) % if there are spikes in the unit
  
    last3Batches = [0,0,0];
    for jj = 0:2
        if c-jj > 0
            last3Batches(jj+1) = nnz(app.unitArray(unitNum).getAssignedSpikes(getBatchRange(app,[c-jj,c-jj])));
        end
    end
    
    if ~isempty(app.unitArray(unitNum).name)
        nameText = """"+app.unitArray(unitNum).name+""" ";
    else
        nameText = "";
    end
    
    if strcmpi("Junk",app.unitArray(unitNum).tags)
        junkText = "  JUNK UNIT";
    else
        junkText = "";
    end
    
    txt = nameText + string(length(app.unitArray(unitNum).spikeTimes)) +...
        " spikes total, " + last3Batches(3) + "/" + last3Batches(2) +...
        "/" + last3Batches(1) + " spikes -2/-1/0 batches ago" + junkText;
    
elseif ~isempty(app.unitArray(unitNum).loadedTemplateWaves)
    txt = "TEMPLATE SPIKES ONLY";
    
else
    txt = "No spikes!";
    
end

end