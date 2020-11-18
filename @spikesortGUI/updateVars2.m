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

if isfield(newT,'rawSpikeSample')
    app.t = newT;
elseif isfield(newT,'batchSize')
    app.t = newT;
    app.t.rawSpikeSample = [];
    app.t.spikeClust = []; %???
else
    app.t.rawSpikeSample = [];
    app.t.spikeClust = [];
    
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
                end
                app.t.numSpikesInBatch(length(newT.spikeClust)+1:length(app.t.batchLengths)) = 0;
            else
                app.t.numSpikesInBatch(1:length(app.t.batchLengths)) = 0;
            end
            break;
        end
    end
end


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
                app.m.mainCh, [], [], [], [], 1);
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

%%%LEGACY CHECKS%%%

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
app.VieweventmarkersButton.Value = 0;

%    read and plot data
app.readFilter2(0)
app.redrawTracePlot2(app.figureHandles(1), app.figureHandles(2));
app.redrawUnitPlots2(app.figureHandles);
app.switchButtons(3)

app.updateDropdown();
app.LeftUnitDropDown.Value = "1";
app.RightUnitDropDown.Value = "1";
            
app.historyStack = [];
            
app.StatusLabel.Value = "Ready";
app.addHistory();
end