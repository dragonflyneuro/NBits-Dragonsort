classdef unit < handle
    properties
        waves {mustBeNumeric} = [];
        spikeTimes {mustBeInteger} = [];
        spikeIndex {mustBeInteger} = [];
        tags = string.empty();
        mainCh {mustBeInteger} = 1;
        refineSettings {mustBeNumeric} = 1;
        loadedTemplateWaves {mustBeNumeric} = [];
        loadedTemplateMapping = struct("originFile", [],...
                    "harvestLocation", [],...
                    "originUnit", []);
    end
    
    methods
        function obj = unit(varargin)                      
            if nargin > 9
                obj.refineSettings = varargin{10};
            end

            if nargin > 8
                obj.tags = varargin{9};
            end

            if nargin > 4
                obj.loadedTemplateMapping.originFile = varargin{5};
                obj.loadedTemplateMapping.harvestLocation = varargin{6};
                obj.loadedTemplateMapping.originUnit = varargin{7};
                obj.loadedTemplateWaves = varargin{8};
            end

            if nargin > 3
                obj.mainCh = varargin{4};
            end

            % initialise assigned waves
            if nargin > 2
                obj.spikeTimes = varargin{1};
                obj.waves = varargin{2};
                obj.spikeIndex = varargin{3};
            end
        end
        
        function out = copy(obj)
            p = properties(obj);
            out = [];
            for ii = 1:length(obj)
                out = [out, unit()];
                for jj = 1:length(p)
                    out(ii).(p{jj}) = obj(ii).(p{jj});
                end
            end
        end
        
        % 1 unit only
        function [sTimes, sWaves, overallIdx, inUnitIdx] = getAssignedSpikes(obj, t, c, varargin)
            bl = t.batchLengths;
            if nargin > 3
                if strcmpi(varargin{1}, 'all')
                    batchRange = [-c, length(bl)-c];
                else
                    batchRange = varargin{1};
                end
            else
                batchRange = [-1, 0];
            end
            if c + batchRange(2) > length(bl)
                batchRange(2) = length(bl)-c;
            end
            
            bool = sum(bl(1:c+batchRange(1))) < obj.spikeTimes...
            & obj.spikeTimes <= sum(bl(1:c+batchRange(2)));
        
            inUnitIdx = find(bool);
            sTimes = obj.spikeTimes(inUnitIdx);
            sWaves = obj.waves(inUnitIdx,:,:);
            overallIdx = obj.spikeIndex(inUnitIdx);
        end
        
        function [orphanSpikes, orphanWaves, orphanIdx] = getOrphanSpikes(obj, t, c, w, varargin)
            bl = t.batchLengths;
            if nargin > 4
                if strcmpi(varargin{1}, 'all')
                    batchRange = [-c, length(bl)-c];
                else
                    batchRange = varargin{1};
                end
            else
                batchRange = [-1, 0];
            end
            if c + batchRange(2) > length(bl)
                batchRange(2) = length(bl)-c;
            end
            
            nsib = t.numSpikesInBatch;
            cumIdx = [];
            offset = sum(nsib(1:c+batchRange(1)));
            
            for ii = 1:length(obj)
                [~, ~, idx] = getAssignedSpikes(obj(ii), t, c, batchRange);
                cumIdx = [cumIdx, idx];
            end
            orphanIdx = offset+1:sum(nsib(1:c+batchRange(2)));
            orphanIdx(ismember(orphanIdx,cumIdx)) = [];
            orphanWaves = w(orphanIdx-offset,:,:); % unassigned waves
            orphanSpikes = t.rawSpikeSample(orphanIdx); % unassigned spike sample from beginning of batch
        end

        function obj = spikeRemover(obj,n,I)
            n = n(1);
            if isempty(I)
                return;
            end
            
            obj(n).spikeTimes(I) = [];
            obj(n).waves(I,:,:) = [];
            obj(n).spikeIndex(I) = [];
        end
        
        function obj = spikeAdder(obj,t,m,c,w,n,I,force,fuzzy)
            % pick out spikes manually and add them to a unit either by
            % deviation matching or by force
            n = n(1);
            [orphanSpikes, orphanWaves, orphansIndex] = obj.getOrphanSpikes(t,c,w);
            templateWaves = orphanWaves(I,:,:);
            
            if force == 0 % go through deviation matching to add new spikes to unit
                % add loaded template waves if they exist for this unit
                if ~isempty(obj(n).loadedTemplateWaves)
                    templateWaves = [obj(n).loadedTemplateWaves; templateWaves];
                end
                [matches,~] = newTemplateMatch(orphanWaves, templateWaves, m.sRateHz, t.add2UnitThr(2), fuzzy);
                if ~isempty(matches)
                    obj(n).spikeTimes = [obj(n).spikeTimes, orphanSpikes(matches)];
                    obj(n).waves = [obj(n).waves; orphanWaves(matches,:,:)];
                    obj(n).spikeIndex = [obj(n).spikeIndex, orphansIndex(matches)];
                end
            elseif force == 1 % force add spikes to unit - no deviation matching
                obj(n).spikeTimes = [obj(n).spikeTimes, orphanSpikes(I)];
                obj(n).waves = [obj(n).waves; orphanWaves(I,:,:)];
                obj(n).spikeIndex = [obj(n).spikeIndex, orphansIndex(I)];
            end
            obj = obj.unitSorter();
        end
        
        function obj = refinedSpikeAdder(obj,n,a,b,c)
            % pick out spikes manually and add them to a unit either by
            % deviation matching or by force
            n = n(1);
            obj(n).spikeTimes = [obj(n).spikeTimes, a];
            obj(n).waves = cat(1,obj(n).waves, b);
            obj(n).spikeIndex = [obj(n).spikeIndex, c];
        end
        
        function obj = unitSplitter(obj,n,I)
            n = n(1);
            if isempty(I)
                return;
            end
            
            newUnit = unit(obj(n).spikeTimes(I),obj(n).waves(I,:,:),obj(n).spikeIndex(I),obj(n).mainCh);
            
            obj(n).spikeTimes(I) = [];
            obj(n).waves(I,:,:) = [];
            obj(n).spikeIndex(I) = [];
            
            newUnit = newUnit.tagToggler("Junk");
            
            obj = [obj newUnit];
        end
        
        function obj = unitMerger(obj,n,I)
            % merge the left unit into the right unit
            % remove left unit and merge with right
            if isempty(I)
                I = 1:length(obj(n(1)).spikeTimes);
            end
            
            mergedUnit = cat(2,obj(n(1)).spikeTimes(I),obj(n(2)).spikeTimes);
            [obj(n(2)).spikeTimes, order] = sort(mergedUnit);
            mergedWaves = cat(1,obj(n(1)).waves(I,:,:),obj(n(2)).waves);
            obj(n(2)).waves = mergedWaves(order,:,:);
            obj(n(2)).spikeIndex = [obj(n(2)).spikeIndex, obj(n(1)).spikeIndex(I)];
            obj(n(2)).refineSettings = 1;
            
            obj(n(1)).spikeTimes(I) = [];
            obj(n(1)).waves(I,:,:) = [];
            obj(n(1)).spikeIndex(I) = [];
            
            obj(n(2)) = obj(n(2)).tagToggler("Junk",0);
            
            if isempty(obj(n(1)).spikeTimes)
                obj(n(1)) = [];
            end
        end
        
        function obj = unitRefactorer(obj)
            if length(obj) == 1
                return;
            end
            
            flag = false(size(obj));
            for ii = 1:length(obj)
                if isempty(obj(ii).spikeTimes)
                    flag(ii) = true;
                end
            end
            obj(flag) = [];
            
            % find order of peak amplitude
            minMean = zeros(1,length(obj));
            for ii = 1:length(obj)
                waveAmp = min(mean(obj(ii).waves(:,:,obj(ii).mainCh),1));
                minMean(ii) = waveAmp;
            end
            [~, unitOrder] = sort(minMean);
            
            obj = obj(unitOrder);
        end
        
        function obj = unitSorter(obj)
            for ii = 1:length(obj)
                [obj(ii).spikeTimes, order, ~] = unique(obj(ii).spikeTimes);
                obj(ii).waves = obj(ii).waves(order,:,:);
                obj(ii).spikeIndex = sort(obj(ii).spikeIndex);
            end
        end
        
        function [bool, idx] = tagcmpi(obj,tagstr)
            bool = false(size(obj));
            idx = zeros(size(obj));
            for ii = 1:length(obj)
                numTags = length(obj(ii).tags);
                for jj = 1:numTags
                    query = strcmpi(tagstr, obj(ii).tags(jj));
                    if any(query)
                        bool(ii) = true;
                        idx(ii) = find(query);
                        break;
                    end
                end
            end
        end
        
        function obj = tagToggler(obj,str,varargin)
            [b, i] = obj.tagcmpi(str);
            if nargin > 2
                if varargin == 1
                    for ii = find(~b)
                        obj(ii).tags(end+1) = str;
                    end
                else
                    for ii = find(b)
                        obj(ii).tags(i) = [];
                    end
                end
            else
                for ii = find(~b)
                    obj(ii).tags(end+1) = str;
                end
                for ii = find(b)
                    obj(ii).tags(i) = [];
                end
            end
        end
        
    end
end