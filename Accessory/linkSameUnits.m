function [s, log] = linkSameUnits()
% get sorting files
fT = 1;
numFiles = 0;
while fT > 0
    [fT, pT] = uigetfile("*.mat",...
        "Select in order of time oldest to newest! Cancel/ESC when done.");
    if fT > 0
        numFiles = numFiles+1;
        fN{numFiles} = fT;
        pN{numFiles} = pT;
        s(numFiles) = load([pN{numFiles},fN{numFiles}]);
    end
end
if numFiles < 2
    s = [];
    log = "linking aborted - need more than one sorting";
    return;
end
log = "unit linking start with "+numFiles+" sortings";

for ii = 1:length(s(1).unitArray)
    s(1).unitArray(ii).name= string(ii);
end
unitArray = s(1).unitArray;
m = s(1).m;
t = s(1).t;
if isfield(s(1),'stim')
    stim = s(1).stim;
    save([pN{1},fN{1}],'unitArray','m','t','stim');
else
    save([pN{1},fN{1}],'unitArray','m','t');
end

% do deviation match to see if any of the units of the later sortings match
% any of the units of the sorting directly before it
thr = 0.4;
maxSoFar = 0;
for ii = 1:numFiles-1
    for jj = 1:length(s(ii+1).unitArray)
        % do template matching of all waves in a later sorted unit to all
        % units ofan earlier sorting
        d = newGetDevMatrix(1,s(ii).unitArray,s(ii+1).unitArray(jj).waves,[0 inf],60,s(ii).m.sRateHz,0);
        % get closest unit for each wave
        [val, idx] = min(d,[],2);
        % get closest overwall wave
        closestUnit = mode(idx);
        % get mean deviation to closest unit by select waves
        meanDev = mean(val(idx == closestUnit));
        if meanDev < thr % accepted link if dev is low enough
            s(ii+1).unitArray(jj).name = s(ii).unitArray(closestUnit).name;
            log(end+1,1) = "unit linking accepted sorting"...
                +(ii+1)+" unit"+jj+" to unit"+closestUnit+" dev:"+meanDev;
            disp(log(end));
        else % rejected link if dev is too high
            for kk = 1:ii
                maxSoFar = max([str2double([s(kk).unitArray.name]), maxSoFar]);
            end
            maxSoFar = maxSoFar+1;
            % assign a non overlapping unit name for future sortings
            s(ii+1).unitArray(jj).name = string(maxSoFar);
            log(end+1,1) = "unit linking rejected... sorting"...
                +(ii+1)+" unit"+jj+" dev="+meanDev;
            disp(log(end));
        end
    end
    % if merging is detected let it be known
    if length(unique([s(ii+1).unitArray.name])) ~= length([s(ii+1).unitArray.name])
        log(end+1,1) = "merging contamination detected sorting"+(ii+1);
        disp(log(end));
    end
    
    % save sorting back
    unitArray = s(ii+1).unitArray;
    m = s(ii+1).m;
    t = s(ii+1).t;
    if isfield(s(ii+1),'stim')
        stim = s(ii+1).stim;
        save([pN{ii+1},fN{ii+1}],'unitArray','m','t','stim');
    else
        save([pN{ii+1},fN{ii+1}],'unitArray','m','t');
    end
    log(end+1,1) = "saved sorting"+(ii+1)+" as "+fN{ii+1};
    disp(log(end));
end

end