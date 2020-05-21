function e = updateVars(app, newM, newT, newS)
e = 0;
%    user input data
app.StatusLabel.Value = "Loading...";
drawnow

app.m = newM;
% find dataset
fileNotFound = 1;
while fileNotFound ~= 0
    app.fid = fopen([app.m.fP app.m.fN],'r');
    if app.fid < 1 || fileNotFound == -1
        [app.m.fN, app.m.fP] = uigetfile('*.bin',"Could not find/open binary file! Please reselect");
        figure(app.UIBase);
        if app.m.fN < 1
            app.m = [];
            e = 1;
            if app.fid > 0
                fclose(app.fid);
            end
            return;
        end
    else
        fseek(app.fid,0,'eof');
        nFileSizeBytes = ftell(app.fid);
        if nFileSizeBytes == app.m.fileSizeBytes
            fileNotFound = 0;
        else
            fileNotFound = -1;
        end
    end
end
fseek(app.fid,0,'bof');

app.s = [];
app.s.clusters = "1";
app.s.unit_1 = [];
app.s.waves_1 = [];

app.t = [];

if isfield(newT,'rawSpikeSample')
    app.t = newT;
elseif isfield(newT,'batchSize')
    app.t = newT;
    app.t.rawSpikeSample = [];
    app.t.spikeClust = [];
    app.t.orphanBool = logical.empty();
else
    app.t.rawSpikeSample = [];
    app.t.spikeClust = [];
    app.t.orphanBool = logical.empty();
    %%%LEGACY CHECKS%%%
    
    if ~isfield(app.m, 'el_cutL')
        app.m.el_cutL = 7000;
        app.m.el_cutH = app.m.el_cut;
        app.m = rmfield(app.m, "el_cut");
    end
    
    if ~isfield(newT,'yscale')
        if isfield(app.m,'yscale')
            app.t.yscale = app.m.yscale;
            app.m = rmfield(app.m, "yscale");
        else
            app.t.yscale = 1;
        end
    else
        app.t.yscale = newT.yscale;
    end
    
    if isfield(app.m, 'splitSize')
        app.t.batchSize = app.m.splitSize;
        app.t.saveNameSuffix = app.m.postName;
        app.t.detectThr = app.m.ampThreshold;
        if isfield(app.m, 'oldTempSTDThreshold')
            app.t.add2UnitThr(1) = app.m.oldTempSTDThreshold;
            app.t.add2UnitThr(2) = app.m.newTempSTDThreshold;
            app.m = rmfield(app.m, ["oldTempSTDThreshold", "newTempSTDThreshold"]);
        else
            app.t.add2UnitThr(1) = app.m.oldTempSTDTh;
            app.t.add2UnitThr(2) = app.m.newTempSTDTh;
            app.m = rmfield(app.m, ["oldTempSTDTh", "newTempSTDTh"]);
        end
        
        app.m = rmfield(app.m, ["splitSize", "postName", "ampThreshold"]);
    end
    
    tNames = fieldnames(newT);
    for ii = 1:length(tNames)
        if contains(tNames{ii}, ["spikeBatchNum","spikeIdxInBatch"])
            batchNum = floor(app.m.fileSizeBytes/(app.m.dbytes*app.m.nChans*app.t.batchSize));
            app.t.batchLengths = [app.t.batchSize*ones(1, batchNum),  app.m.fileSizeBytes/(app.m.dbytes*app.m.nChans)-app.t.batchSize*batchNum]; %in samples
            bL = [0 cumsum(app.t.batchLengths)];
            app.t.numSpikesInBatch = [];
            if isfield(newT,"rawSpikeIdx")
                for jj = 1:length(newT.spikeClust)
                    app.t.rawSpikeSample = [app.t.rawSpikeSample, newT.rawSpikeIdx{jj} + bL(jj)];
                    app.t.numSpikesInBatch(jj) = length(newT.spikeClust{jj});
                    app.t.spikeClust = [app.t.spikeClust, newT.spikeClust{jj}];
                    app.t.orphanBool = [app.t.orphanBool, newT.orphanBool{jj}];
                end
                app.t.numSpikesInBatch(length(newT.spikeClust)+1:length(app.t.batchLengths)) = 0;
            else
                app.t.numSpikesInBatch(1:length(app.t.batchLengths)) = 0;
            end
            break;
        end
    end
end

if length(app.t.detectThr) == 1
    app.t.detectThr(2) = -inf;
end

if isfield(app.s, 'junkNames')
    app.s.tags = table('RowNames', "Junk");
    for ii = app.s.clusters
        app.s.tags.("unit_"+ii) = ismember(ii, app.s.junkNames);
    end
    app.s = rmfield(app.s, 'junkNames');
end

if ~isfield(app.t, 'noSpikeRange')
    app.t.noSpikeRange = [];
end

%%%LEGACY CHECKS%%%

if ~isempty(newS)
    app.s = newS;
    if ~isfield(app.t, 'refineSettings')
        app.t.refineSettings = {app.s.clusters, ones(size(app.s.clusters))};
    end
end
if ~isfield(app.t, 'refineSettings')
    app.t.refineSettings = {"1", 1};
end

if ~isfield(app.s, 'tags')
    app.s.tags = table('RowNames', "Junk");
    for ii = app.s.clusters
        app.s.tags.("unit_"+ii) = false;
    end
end

%    derived data
app.t.detectThr = sort(app.t.detectThr);
app.currentBatch = 1;
batchNum = floor(app.m.fileSizeBytes/(app.m.dbytes*app.m.nChans*app.t.batchSize));
app.t.batchLengths = [app.t.batchSize*ones(1, batchNum), app.m.fileSizeBytes/(app.m.dbytes*app.m.nChans)-app.t.batchSize*batchNum];
if ~isfield(app.t,'numSpikesInBatch')
    app.t.numSpikesInBatch = zeros(size(app.t.batchLengths));
end
app.msConvert = 1000/app.m.sRateHz;
if ~isempty(app.t.saveNameSuffix)
    suffix = "_"+app.t.saveNameSuffix;
else
    suffix = "";
end

%    update gui fields
app.BatchsizeEditField.Value = app.t.batchSize;
app.OldField.Value = app.t.add2UnitThr(1);
app.NewField.Value = app.t.add2UnitThr(2);
app.DetectThr1EditField.Value = app.t.detectThr(1);
app.DetectThr2EditField.Value = app.t.detectThr(2);
app.BinaryEditField.Value = app.m.fN;
app.SavenameEditField.Value ="sorting_" + erase(app.m.fN,'.bin') + suffix;
app.LeftUnitDropDown.Items = "1";
app.RightUnitDropDown.Items = "1";
app.LeftUnitDropDown.Value = "1";
app.RightUnitDropDown.Value = "1";

%    read and plot data
readFilter(app, 0, 0)
app.redrawTracePlot();
app.redrawUnitPlots();
switchButtons(app,3)
end