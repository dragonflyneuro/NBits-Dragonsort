function h = scatterDK(posData, varargin)

if nargin > 5
    sizeData = varargin{4};
else
    sizeData = 20*ones(size(posData));
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
            h(ii) = scatter(ax, posData{ii}(:,1),posData{ii}(:,2),sizeData(ii),...
                repmat(colourData(ii,:),[size(posData{ii},1),1]),"Marker",markerData(ii));
        else
            h(ii) = scatter3(ax, posData{ii}(:,1),posData{ii}(:,2),posData{ii}(:,3),...
                sizeData(ii),repmat(colourData(ii,:),[size(posData{ii},1),1]),"Marker",markerData(ii));
        end
    end
end