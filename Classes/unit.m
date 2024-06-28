classdef unit < handle
    properties
        name = string.empty();
        waves {mustBeNumeric} = [];
        spikeTimes {mustBeInteger} = [];
        tags = string.empty();
        mainCh {mustBeInteger} = 1;
        refineSettings {mustBeNumeric} = 1;
        meanDeviation {mustBeNumeric} = 0;
        loadedTemplateWaves {mustBeNumeric} = [];
        loadedTemplateMapping = struct("originFile", [],...
                    "harvestLocation", [],...
                    "originUnit", []);
    end
    
    methods
        function obj = unit(varargin)                      
            if nargin > 8
                obj.refineSettings = varargin{9};
            end

            if nargin > 7
                obj.tags = varargin{8};
            end

            if nargin > 3
                obj.loadedTemplateMapping.originFile = varargin{4};
                obj.loadedTemplateMapping.harvestLocation = varargin{5};
                obj.loadedTemplateMapping.originUnit = varargin{6};
                obj.loadedTemplateWaves = varargin{7};
            end

            if nargin > 2
                obj.mainCh = varargin{3};
            end

            % initialise assigned waves
            if nargin > 1
                obj.spikeTimes = varargin{1};
                obj.waves = varargin{2};
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
        function [sTimes, sWaves, inUnitIdx] = getAssignedSpikes(obj, range)
            bool = range(1) < obj.spikeTimes & obj.spikeTimes <= range(2);
        
            inUnitIdx = find(bool);
            sTimes = obj.spikeTimes(inUnitIdx);
            sWaves = obj.waves(inUnitIdx,:,:);
        end
        
        function [unassignedSpikes, inSortingIdx, inRangeIdx] = getOrphanSpikes(obj, allTimes, range)          
            allT = [];
            
            for ii = 1:length(obj)
                [t, ~, ~] = getAssignedSpikes(obj(ii), range);
                allT = [allT, t];
            end
            inSortingIdx = find(range(1) < allTimes & allTimes <= range(2));
            inRangeIdx = 1:length(inSortingIdx);
            
            assigned = ismember(allTimes(inSortingIdx),allT);
            inSortingIdx(assigned) = [];
            inRangeIdx(assigned) = [];
            unassignedSpikes = allTimes(inSortingIdx); % unassigned spike sample from beginning of batch
        end

        function [obj, e] = spikeAdder(obj,uIdx,a,b)
            % pick out spikes manually and add them to a unit either by
            % deviation matching or by force
            uIdx = uIdx(1);
            if length(a) == size(b,1)
                obj(uIdx).spikeTimes = [obj(uIdx).spikeTimes, a];
                obj(uIdx).waves = [obj(uIdx).waves; b];
                obj = obj.unitSorter();
            end
            e = [];
        end
        
        function [obj, e] = refinedSpikeAdder(obj,uIdx,a,b)
            % pick out spikes manually and add them to a unit either by
            % deviation matching or by force
            uIdx = uIdx(1);
            obj(uIdx).spikeTimes = [obj(uIdx).spikeTimes, a];
            obj(uIdx).waves = cat(1,obj(uIdx).waves, b);
            e = [];
        end
        
        function [obj, e] = spikeRemover(obj,uIdx,I,varargin)
            uIdx = uIdx(1);
            if nargin > 3
                force = varargin{1};
            else
                force = 0;
            end
            
            if isempty(I)
                e = "No spikes selected for operation";
                return;
            elseif isempty(setdiff(1:length(obj(uIdx).spikeTimes),I)) && ~force
                e = "All spikes in unit selected, no changes will be made";
                return;
            end
            
            obj(uIdx).spikeTimes(I) = [];
            obj(uIdx).waves(I,:,:) = [];
            e = [];
        end

        function [obj, e] = unitSplitter(obj,uIdx,I, varargin)
            uIdx = uIdx(1);
            if nargin > 3
                force = varargin{1};
            else
                force = 0;
            end
            
            if isempty(I)
                e = "No spikes selected for operation";
                return;
            elseif ((~islogical(I) && length(I) == length(obj(uIdx).spikeTimes)) || ...
                    (islogical(I) && all(I))) && ~force
                e = "All spikes in unit selected, no changes will be made";
                return;
            end
            newObj = unit(obj(uIdx).spikeTimes(I),obj(uIdx).waves(I,:,:),obj(uIdx).mainCh);
            
            obj(uIdx).spikeTimes(I) = [];
            obj(uIdx).waves(I,:,:) = [];
            
            newObj.loadedTemplateWaves = obj(uIdx).loadedTemplateWaves;
            newObj.loadedTemplateMapping = obj(uIdx).loadedTemplateMapping;
            
            obj = [obj newObj];
            e = [];
        end
        
        function [obj, e] = unitMerger(obj,uIdx,I)
            % merge the left unit into the right unit
            % remove left unit and merge with right
            if uIdx(1) == uIdx(2)
                e = "Left and right units are the same";
                return;
            end
            if isempty(I)
                I = 1:length(obj(uIdx(1)).spikeTimes);
            end
            
            mergedUnit = cat(2,obj(uIdx(1)).spikeTimes(I),obj(uIdx(2)).spikeTimes);
            [obj(uIdx(2)).spikeTimes, order] = sort(mergedUnit);
            mergedWaves = cat(1,obj(uIdx(1)).waves(I,:,:),obj(uIdx(2)).waves);
            obj(uIdx(2)).waves = mergedWaves(order,:,:);
            obj(uIdx(2)).refineSettings = 1;
            
            obj(uIdx(1)).spikeTimes(I) = [];
            obj(uIdx(1)).waves(I,:,:) = [];
            
            obj(uIdx(2)) = obj(uIdx(2)).tagToggler("Junk",0);
            
            if isempty(obj(uIdx(1)).spikeTimes)
                obj(uIdx(1)) = [];
            end
            e = [];
        end
        
        function [obj, e] = unitRefactorer(obj)
            if length(obj) == 1
                e = "There is only one unit - refactoring aborted";
                return;
            end
            
            flag = false(size(obj));
            for ii = 1:length(obj)
                if isempty(obj(ii).spikeTimes) && isempty(obj(ii).loadedTemplateWaves)
                    flag(ii) = true;
                end
            end
            obj(flag) = [];
            
            % find order of peak amplitude
            minMean = zeros(1,length(obj));
            for ii = 1:length(obj)
                if isempty(obj(ii).spikeTimes)
                    waveAmp = min(mean(obj(ii).loadedTemplateWaves(:,:,obj(ii).mainCh),1));
                else
                    waveAmp = min(mean(obj(ii).waves(:,:,obj(ii).mainCh),1));
                end
                minMean(ii) = waveAmp;
            end
            [~, unitOrder] = sort(minMean);
            
            obj = obj(unitOrder);
            e = [];
        end
        
        function obj = unitSorter(obj)
            for ii = 1:length(obj)
                [obj(ii).spikeTimes, order, ~] = unique(obj(ii).spikeTimes);
                obj(ii).waves = obj(ii).waves(order,:,:);
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
                if varargin{1} == 1
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