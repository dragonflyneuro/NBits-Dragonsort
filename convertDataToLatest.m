function log = convertDataToLatest(filterSpec)
%refilter is a cell array:
%{filter order}
%{filter cutoffs}
%{filter firstband pass/stop}

p = uigetdir;
log = recursiveConvert(p,filterSpec);
cd(p);
log(end+1,1) = "done!";
disp("done");
end

function log = recursiveConvert(p, fS)
log = string(p);
disp(log(end));
[pn, isdir] = getValidPaths(p);
cd(p);

for ii=1:length(pn)
    if ~isdir(ii)
        continue
    end
    newLog = recursiveConvert(pn{ii},fS);
    log = [log; newLog];
end
for ii=1:length(pn)
    if ~isdir(ii)
        [~, ~, fExt] = fileparts(pn{ii});
        if ~strcmpi(fExt,'.mat')
            continue
        end
        
        inFile = whos('-file',pn{ii});
        if ~any(strcmp('m',{inFile(:).name})) || ~any(strcmp('t',{inFile(:).name}))
            continue
        end
        if ~any(strcmp('s',{inFile(:).name}))
            newData = load(pn{ii},'m','t','unitArray');
            log(end+1,1) = filesep+string(pn{ii})+" preserved";
            disp(log(end))
        else
            tData = load(pn{ii},'m','s','t');
            [newData.m, newData.t, newData.unitArray] = convertToUnit(tData.m,tData.t,tData.s);
            log(end+1,1) = filesep+string(pn{ii})+" converted";
            disp(log(end))
        end
        
        if ~isempty(fS)
            [newData, log] = refilterer(newData, log, fS);
            log(end+1,1) = filesep+string(pn{ii})+" refiltered";
            disp(log(end))
        end
        unitArray = newData.unitArray;
        m = newData.m;
        t = newData.t;
        save([erase(pn{ii},'.mat'), '_ds3.mat'],'unitArray','m','t');
    end
end
cd('..');
end

function [nd, log] = refilterer(nd, log, filterSpec)
if ~(filterSpec{1} ~= nd.m.filterSpec.order ||...
        any(filterSpec{2} ~= nd.m.filterSpec.cutoffs) ||...
        any(filterSpec{3} ~= nd.m.filterSpec.firstBandMode))
    return;
end

nd.m.filterSpec.order = filterSpec{1};
nd.m.filterSpec.cutoffs = filterSpec{2};
nd.m.filterSpec.firstBandMode = filterSpec{3};
if strcmpi(nd.m.filterSpec.firstBandMode, 'stop')
    filterVec = fir1(nd.m.filterSpec.order,...
        nd.m.filterSpec.cutoffs./(nd.m.sRateHz/2),'DC-0');
else
    filterVec = fir1(nd.m.filterSpec.order,...
        nd.m.filterSpec.cutoffs./(nd.m.sRateHz/2),'DC-1');
end

data = getBinary(nd);
bl = nd.t.batchLengths;
searchArea = 2;
for ii = 1:length(nd.t.batchLengths)
    range = sum(bl(1:ii-1)):sum(bl(1:ii));
    x = double(nd.t.yscale*data(:,range(2:end))); % little endian open
    xi = splitconv(x(nd.m.ech,:),filterVec);
    yOffset = prctile(xi,50,2); %yoffset = mean(xi,2);
    xi = xi - yOffset(1:size(xi,1),:); % remove DC offset
    
    
    [~, detectedSpikes] = spike_times2(xi(nd.m.mainCh, 1:end-nd.m.spikeWidth), nd.t.detectThr(2), -1); % aligned to negative peak
    detectedSpikes = detectedSpikes(detectedSpikes > nd.m.spikeWidth+1);
    detectedSpikes(xi(nd.m.mainCh,detectedSpikes) < nd.t.detectThr(1)) = [];
    offsetSpikes = detectedSpikes + sum(bl(1:ii-1));
    if ~isempty(nd.t.noSpikeRange)
        for jj = 1:size(nd.t.noSpikeRange,2)
            offsetSpikes(offsetSpikes >= nd.t.noSpikeRange(1,jj) & offsetSpikes <= nd.t.noSpikeRange(2,jj)) = [];
        end
    end
    
    % for each unit, get updated peak times and waveforms
    oldSpikeBool = range(1) < nd.t.rawSpikeSample & nd.t.rawSpikeSample <= range(end);
    if any(offsetSpikes) ~= nd.t.rawSpikeSample(oldSpikeBool)
        log(end+1,1) = "batch "+ii+" "+string(length(offsetSpikes)-sum(oldSpikeBool))+" spikes added";
        disp(log(end))
        
        for jj = 1:length(nd.unitArray)
            [sTimes, ~, unitIdx] = nd.unitArray(jj).getAssignedSpikes([range(1), range(end)]);
            matchedSpikes = interp1(offsetSpikes,offsetSpikes,sTimes,'nearest','extrap');
            deletedSpikes = abs(sTimes-matchedSpikes) > searchArea;
            sameSpikes = sTimes-matchedSpikes == 0;

            nd.unitArray(jj).spikeTimes(unitIdx) = matchedSpikes;
            for kk = find(~sameSpikes)
                newWave = xi(:, matchedSpikes(kk)-range(1)+(-nd.m.spikeWidth:nd.m.spikeWidth));
                nd.unitArray(jj).waves(unitIdx(kk),:,:) = permute(newWave, [3 2 1]);
            end
            nd.unitArray = nd.unitArray.spikeRemover(jj,unitIdx(deletedSpikes));

            prevCount = length(nd.unitArray(jj).spikeTimes);
            nd.unitArray(jj) = nd.unitArray(jj).unitSorter();
            newCount = length(nd.unitArray(jj).spikeTimes);
            
            if any(deletedSpikes)
                log(end+1,1) = "batch "+ii+" unit "+jj+" "+sum(deletedSpikes)+" spikes removed";
                disp(log(end))
            end
            if prevCount-newCount ~= 0
                log(end+1,1) = "batch "+ii+" unit "+jj+" "+(prevCount-newCount)+" spikes merged";
                disp(log(end))
            end
            if any(~sameSpikes)
                log(end+1,1) = "batch "+ii+" unit "+jj+" "+sum(~sameSpikes)+" spikes nudged";
                disp(log(end))
            end
        end
        
        allSpikes = [nd.unitArray.spikeTimes];
        [~,IA] = unique(allSpikes);
        dupIdx = setdiff(1:length(allSpikes), IA);
        dupVal = allSpikes(dupIdx);
        if ~isempty(dupVal)
            log(end+1,1) = "batch "+ii+" "+length(dupVal)+" assigned spikes merged";
            disp(log(end))
            for jj = length(nd.unitArray):-1:2
                [lia, locb] = ismember(nd.unitArray(jj).spikeTimes,dupVal);
                nd.unitArray = nd.unitArray.spikeRemover(jj,lia);
                dupVal(locb(find(locb))) = [];
            end
        end
        nd.t.rawSpikeSample = [nd.t.rawSpikeSample(1:find(oldSpikeBool,1,'first')), offsetSpikes, ...
            nd.t.rawSpikeSample(find(oldSpikeBool,1,'last')+1:end)];
    end
    
end
end

function [x,e] = getBinary(newData)
fileNotFound = 1;
while fileNotFound ~= 0
    try
        fm = memmapfile(newData.m.fN,'Format','int16','Writable',false);
        fileNotFound = 0;
    catch
        try
            fm = memmapfile([newData.m.fP newData.m.fN],'Format','int16','Writable',false);
            fileNotFound = 0;
        catch
            fileNotFound = -1;
        end
    end
    if fileNotFound == -1
        [newData.m.fN, newData.m.fP] = uigetfile('*.bin',"Reselect binary for: "+string(newData.m.fN));
        if newData.m.fN < 1
            newData.m = [];
            e = 1;
            return;
        end
    else
        if size(fm.Data,1)*size(fm.Data,2)*2 == newData.m.fileSizeBytes
            fileNotFound = 0;
        else
            fileNotFound = -1;
        end
    end
end
try
    fm = memmapfile(newData.m.fN,...
        'Format',{'int16',[newData.m.nChans, newData.m.fileSizeBytes/(newData.m.dbytes*newData.m.nChans)],'d'},...
        'Writable',false);
catch
    fm = memmapfile([newData.m.fP newData.m.fN],...
        'Format',{'int16',[newData.m.nChans, newData.m.fileSizeBytes/(newData.m.dbytes*newData.m.nChans)],'d'},...
        'Writable',false);
end
x = fm.Data.d;

end

function [out, isdir] = getValidPaths(p)
d = dir(p);
pn = strfind({d.name},'.');
validpn = cellfun(@(x)isempty(x),pn);
validpn(~validpn) = cellfun(@(x)x(1)~=1,pn(~validpn));
out = {d(validpn).name};
isdir = [d(validpn).isdir];
end
