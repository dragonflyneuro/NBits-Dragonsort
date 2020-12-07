function [m,t,uA] = convertToUnit(newM,newT,newS)
%%%LEGACY CHECKS%%%

uA = unit();
m = newM;
% t struct %%%%%%%%%%%%%
if isfield(newT,'rawSpikeSample')
    t = newT;
elseif isfield(newT,'batchSize')
    t = newT;
    t.rawSpikeSample = [];
    t.spikeClust = []; %???
else
    t.rawSpikeSample = [];
    t.spikeClust = [];
    
    if ~isfield(newT,'yscale')
        if isfield(m,'yscale')
            t.yscale = m.yscale;
            m = rmfield(m, "yscale");
        else
            t.yscale = 1;
        end
    else
        t.yscale = newT.yscale;
    end
    
    if isfield(m, 'splitSize')
        t.batchSize = m.splitSize;
        t.saveNameSuffix = m.postName;
        t.detectThr = m.ampThreshold;
        if isfield(m, 'oldTempSTDThreshold')
            t.add2UnitThr(1) = m.oldTempSTDThreshold;
            t.add2UnitThr(2) = m.newTempSTDThreshold;
            m = rmfield(m, ["oldTempSTDThreshold", "newTempSTDThreshold"]);
        else
            t.add2UnitThr(1) = m.oldTempSTDTh;
            t.add2UnitThr(2) = m.newTempSTDTh;
            m = rmfield(m, ["oldTempSTDTh", "newTempSTDTh"]);
        end
        
        m = rmfield(m, ["splitSize", "postName", "ampThreshold"]);
    end
    
    tNames = fieldnames(newT);
    for ii = 1:length(tNames)
        if contains(tNames{ii}, ["spikeBatchNum","spikeIdxInBatch"])
            batchNum = floor(m.fileSizeBytes/(m.dbytes*m.nChans*t.batchSize));
            t.batchLengths = [t.batchSize*ones(1, batchNum),  m.fileSizeBytes/(m.dbytes*m.nChans)-t.batchSize*batchNum]; %in samples
            bL = [0 cumsum(t.batchLengths)];
            if isfield(newT,"rawSpikeIdx")
                for jj = 1:length(newT.spikeClust)
                    t.rawSpikeSample = [t.rawSpikeSample, newT.rawSpikeIdx{jj} + bL(jj)];
                    t.spikeClust = [t.spikeClust, newT.spikeClust{jj}];
                end
            end
            break;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%

% m struct %%%%%%%%%%%%%%
if ~isfield(m, 'filterSpec')
    m.filterSpec.order = m.el_flen;
    if isfield(m,'el_cut')
        m.filterSpec.cutoffs = m.el_cut;
        m.filterSpec.firstBandMode = 'stop';
        m = rmfield(m, 'el_cut');
    else
        m.filterSpec.cutoffs = [m.el_cutH, m.el_cutL];
        m.filterSpec.firstBandMode = 'stop';
        m = rmfield(m, ["el_cutH", "el_cutL"]);
    end
    m = rmfield(m, 'el_flen');
    m = rmfield(m, 'el_f');
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% detection threshold %%%
if length(t.detectThr) == 1
    t.detectThr(2) = -inf;
end
%%%%%%%%%%%%%%%%%%%%%%%%%

% no spike zones %%%%%%%%
if ~isfield(t, 'noSpikeRange')
    t.noSpikeRange = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(newS)
    if isfield(newS,'clusters')
        for ii = 1:length(newS.clusters)
            % spikes & waves %%%%%%%%
            uA(ii) = unit(newS.("unit_"+newS.clusters(ii)),...
                newS.("waves_"+newS.clusters(ii)),...
                m.mainCh);
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            % templates %%%%%%%%%%%%%
            if isfield(newT,"importedTemplateOriginFileName")
                hasImported = strcmpi(newS.clusters(ii), newT.importedTemplateMapping{2}(:,1));
                if any(hasImported)
                    templateName = newT.importedTemplateMapping{2}(hasImported,2);
                    uA(ii).loadedTemplateMapping.originFile = newT.importedTemplateOriginFileName;
                    uA(ii).loadedTemplateMapping.harvestLocation = newT.importedTemplateMapping{1}(1,6);
                    uA(ii).loadedTemplateMapping.originUnit = ...
                        newT.importedTemplateMapping{1}(str2double(templateName),5);
                    uA(ii).loadedTemplateWaves = newT.("template_"+templateName);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            % tags %%%%%%%%%%%%%%%%%%
            if isfield(newS, 'junkNames') && ismember(newS.clusters(ii), newS.junkNames)
                uA(ii).tags = "Junk";
            end
            if isfield(newS,"tags")
                uA(ii).tags = string(newS.tags.Properties.RowNames(newS.tags.("unit_"+ii)));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%
        end
    else
        uA = newS;
    end
end

if isfield(t, 'spikeClust')
    t = rmfield(t, 'spikeClust');
end
if isfield(t,'numSpikesInBatch')
    t = rmfield(t,'numSpikesInBatch');
end
%%%LEGACY CHECKS%%%

%    derived data
t.detectThr = sort(t.detectThr);
batchNum = floor(m.fileSizeBytes/(m.dbytes*m.nChans*t.batchSize));
t.batchLengths = [t.batchSize*ones(1, batchNum), m.fileSizeBytes/(m.dbytes*m.nChans)-t.batchSize*batchNum];

end