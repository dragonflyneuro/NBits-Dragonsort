classdef uiToggleGroup < handle
    properties
        bH = gobjects(0); % button handles
    end
    
    methods
        function obj = uiToggleGroup(h, varargin)
            if nargin > 1
                ud = varargin{1};
            else
                ud = [];
            end
            if isempty(ud) || length(h) ~= length(ud)
                return
            end
            
            obj.bH = gobjects(1,length(h));
            for ii = 1:length(h)
                obj.bH(ii) = h(ii);
                if ~isempty(ud)
                    if iscell(ud)
                        obj.bH(ii).UserData{1} = ud{ii};
                    else
                        obj.bH(ii).UserData{1} = ud(ii);
                    end
                end
                obj.bH(ii).UserData{2} = ii;
                obj.bH(ii).Value = false;
                obj.bH(ii).ValueChangedFcn = @obj.buttonPushed;
            end
            
            if nargin > 2
                obj.bH(varargin{2}).Value = true;
            else
                obj.bH(1).Value = true;
            end
            
        end
        
        function ud = getUserData(obj)
            ud = obj.bH([obj.bH.Value]).UserData{1};
        end
        
        function [] = buttonPushed(obj, src, ~)
            num = src.UserData{2};
            tog = false(size(obj.bH));
            tog(num) = obj.bH(num).Value;
            tog = num2cell(tog);
            [obj.bH.Value] = deal(tog{:});
        end
    end
end