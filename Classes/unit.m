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
        function [sTimes, sWaves, inSortingIdx, inUnitIdx] = getAssignedSpikes(obj, range)
            bool = range(1) < obj.spikeTimes & obj.spikeTimes <= range(2);
        
            inUnitIdx = find(bool);
            sTimes = obj.spikeTimes(inUnitIdx);
            sWaves = obj.waves(inUnitIdx,:,:);
            inSortingIdx = obj.spikeIndex(inUnitIdx);
        end
        
        function [orphanSpikes, inSortingIdx, inRangeIdx] = getOrphanSpikes(obj, allTimes, range)          
            cumIdx = [];
            
            for ii = 1:length(obj)
                [~, ~, idx] = getAssignedSpikes(obj(ii), range);
                cumIdx = [cumIdx, idx];
            end
            inSortingIdx = find(range(1) < allTimes & allTimes <= range(2));
            inRangeIdx = 1:length(inSortingIdx);
            
            assigned = ismember(inSortingIdx,cumIdx);
            inSortingIdx(assigned) = [];
            inRangeIdx(assigned) = [];
            orphanSpikes = allTimes(inSortingIdx); % unassigned spike sample from beginning of batch
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
        
        function obj = spikeAdder(obj,n,a,b,c)
            % pick out spikes manually and add them to a unit either by
            % deviation matching or by force
            n = n(1);
            if length(a) == size(b,1) && length(c) == size(b,1)
                obj(n).spikeTimes = [obj(n).spikeTimes, a];
                obj(n).waves = [obj(n).waves; b];
                obj(n).spikeIndex = [obj(n).spikeIndex, c];
                obj = obj.unitSorter();
            end
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