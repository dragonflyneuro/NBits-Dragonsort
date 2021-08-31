function h = scatterDK(posData, varargin)

if nargin > 5
    sizeData = varargin{4};
else
    sizeData = 10*ones(size(posData));
end
if nargin > 4
    markerData = varargin{3};
else
    markerData = repmat("*",size(posData));
end
if nargin > 3
    colourData = varargin{2};
else
    colourData = cool(length(posData));
end
if nargin > 2
    ax = varargin{1};
else
    ax = axes;
end

h = gobjects(size(posData));
for ii = 1:length(posData)
    if ~isempty(posData{ii})
        if size(posData{ii},2) == 2
            h(ii) = line(ax, posData{ii}(:,1),posData{ii}(:,2),...
                'MarkerSize',sizeData(ii),...
                'Color',colourData(ii,:),...
                'Marker',markerData(ii),'LineStyle','none');
        else
            h(ii) = line(ax, posData{ii}(:,1),posData{ii}(:,2),posData{ii}(:,3),...
                'MarkerSize',sizeData(ii),...
                'Color',colourData(ii,:),...
                'Marker',markerData(ii),'LineStyle','none');
        end
    end
end