function e = updateVars2(app, newM, newT, newS)
e = 0;
%    user input data
app.StatusLabel.Value = "Loading...";
drawnow

app.unitArray = unit();
app.m = newM;
% find dataset
fileNotFound = 1;
while fileNotFound ~= 0
    try
        app.fm = memmapfile([app.m.fP app.m.fN],'Format','int16','Writable',false);
        fileNotFound = 0;
    catch
        fileNotFound = -1;
    end
    if fileNotFound == -1
        [app.m.fN, app.m.fP] = uigetfile('*.bin',"Couldn't open binary file or wrong file size! Please reselect");
        figure(app.UIBase);
        if app.m.fN < 1
            app.m = [];
            e = 1;
            return;
        end
    else
        if numel(app.fm.Data)*2 == app.m.fileSizeBytes
            fileNotFound = 0;
        else
            fileNotFound = -1;
        end
    end
end
app.fm = memmapfile([app.m.fP app.m.fN],...
    'Format',{'int16',[app.m.nChans, app.m.fileSizeBytes/(app.m.dbytes*app.m.nChans)],'d'},...
    'Writable',false);
app.fid = app.fm.Data.d;
app.t = [];

%%%LEGACY CHECKS%%%

% t struct %%%%%%%%%%%%%
if isfield(newT,'rawSpikeSample')
    app.t = newT;
elseif isfield(newT,'batchSize')
    app.t = newT;
    app.t.rawSpikeSample = [];
    app.t.spikeClust = []; %???
else
    app.t.rawSpikeSample = [];
    app.t.spikeClust = [];
    
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
            if isfield(newT,"rawSpikeIdx")
                for jj = 1:length(newT.spikeClust)
                    app.t.rawSpikeSample = [app.t.rawSpikeSample, newT.rawSpikeIdx{jj} + bL(jj)];
                    app.t.spikeClust = [app.t.spikeClust, newT.spikeClust{jj}];
                end
            end
            break;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%

% m struct %%%%%%%%%%%%%%
if ~isfield(app.m, 'filterSpec')
    app.m.filterSpec.order = app.m.el_flen;
    if isfield(app.m,'el_cut')
        app.m.filterSpec.cutoffs = app.m.el_cut;
        app.m.filterSpec.firstBandMode = 'stop';
        app.m = rmfield(app.m, 'el_cut');
    else
        app.m.filterSpec.cutoffs = [app.m.el_cutH, app.m.el_cutL];
        app.m.filterSpec.firstBandMode = 'stop';
        app.m = rmfield(app.m, ["el_cutH", "el_cutL"]);
    end
    app.m = rmfield(app.m, 'el_flen');
else
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%
% detection threshold %%%
if length(app.t.detectThr) == 1
    app.t.detectThr(2) = -inf;
end
%%%%%%%%%%%%%%%%%%%%%%%%%

% no spike zones %%%%%%%%
if ~isfield(app.t, 'noSpikeRange')
    app.t.noSpikeRange = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(newS)
    if ~isa(newS,'unit')
        for ii = 1:length(newS.clusters)
            % spikes & waves %%%%%%%%
            app.unitArray(ii) = unit(newS.("unit_"+newS.clusters(ii)),...
                newS.("waves_"+newS.clusters(ii)),...
                find(app.t.spikeClust == str2double(newS.clusters(ii))),...
                app.m.mainCh);
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            % templates %%%%%%%%%%%%%
            if isfield(newT,"importedTemplateOriginFileName")
                hasImported = strcmpi(newS.clusters(ii), newT.importedTemplateMapping{2}(:,1));
                if any(hasImported)
                    templateName = newT.importedTemplateMapping{2}(hasImported,2);
                    app.unitArray(ii).loadedTemplateMapping.originFile = newT.importedTemplateOriginFileName;
                    app.unitArray(ii).loadedTemplateMapping.harvestLocation = newT.importedTemplateMapping{1}(1,6);
                    app.unitArray(ii).loadedTemplateMapping.originUnit = ...
                        newT.importedTemplateMapping{1}(str2double(templateName),5);
                    app.unitArray(ii).loadedTemplateWaves = newT.("template_"+templateName);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            % tags %%%%%%%%%%%%%%%%%%
            if isfield(newS, 'junkNames') && ismember(newS.clusters(ii), newS.junkNames)
               app.unitArray(ii).tags = "Junk";
            end
            if isfield(newS,"tags")
               app.unitArray(ii).tags = string(newS.tags.Properties.RowNames(newS.tags.("unit_"+ii)));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%
        end
    else
        app.unitArray = newS;
    end
end

if isfield(app.t, 'spikeClust')
    app.t = rmfield(app.t, 'spikeClust');
end
if isfield(app.t,'numSpikesInBatch')
    app.t = rmfield(app.t,'numSpikesInBatch');
end
%%%LEGACY CHECKS%%%

%    derived data
app.t.detectThr = sort(app.t.detectThr);
app.currentBatch = 1;
batchNum = floor(app.m.fileSizeBytes/(app.m.dbytes*app.m.nChans*app.t.batchSize));
app.t.batchLengths = [app.t.batchSize*ones(1, batchNum), app.m.fileSizeBytes/(app.m.dbytes*app.m.nChans)-app.t.batchSize*batchNum];

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
app.VieweventmarkersButton.Value = 0;

%    read and plot data
app.readFilter2(app.currentBatch)
switchButtons(app,3)

updateDropdown(app);
app.LeftUnitDropDown.Value = "1";
app.RightUnitDropDown.Value = "1";

standardUpdate(app);
end