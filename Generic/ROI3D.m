function included = ROI3D(posData, includable, varargin)
% posData is cell array of x by 3 positions of each dot
% included is a cell array of 1 by x bool of inclusion
% includable is index along posData for datasets that can be included in
% ROI

subplott = @(m,n,p) subtightplot (m, n, p, [0.02 0.05], [0.06 0.03], [0.05 0.05]);

if nargin > 6
    labels = varargin{4};
else
    labels = ["X","Y","Z"];
end
if nargin > 5
    sizeData = varargin{3};
else
    sizeData = 20*ones(size(posData));
end
if nargin > 4
    markerData = varargin{2};
else
    markerData = repmat("*",size(posData));
end
if nargin > 3
    colourData = varargin{1};
else
    colourData = cool(length(posData));
end

views = [1,2;2,3;1,3];
numROI = size(views,1);
roiVal = cell(numROI,1);
included = cell(size(posData));

f = figure('Position',[50 50 1700 650], 'Name','Choose ROI');
for ii = 1:numROI
    ax(ii) = subplott(1,numROI,ii);
    hold(ax(ii),'on');
    axis square
    title(sprintf('View %d',ii));
    xlabel(labels(views(ii,1)));
    ylabel(labels(views(ii,2)));
end
for ii = 1:numROI
    posDataTemp = cellfun(@(x) x(:,views(ii,:),posData),'UniformOutput',false);
    scatterDK(posDataTemp,ax(ii),ColourData,markerData,sizeData);
%     scatter(ax(ii), posData{jj}(:,views(ii,1)),posData{jj}(:,views(ii,2)),sizeData(jj),...
%         repmat(colourData(jj,:),[size(posData{jj},1),1]),"Marker",markerData(jj)); % 3D PCA plot
end
sgtitle('L-R Click within axes to begin your selection polygon, double click to close polygon, ENTER to confirm');

for ii = 1:numROI
    try
        roi(ii) = images.roi.Polygon(ax(ii));
        draw(roi(ii));
    catch
        try
            close(f);
        catch
        end
        
        return;
    end
end

[confirmedFlag, ~] = getFigData(f, 1);
if ~confirmedFlag
    return;
end

for ii = 1:numROI
    roiVal{ii} = roi(ii).Position;
end
close(f);

for ii = includable
    included{ii} = ones(size(posData{ii},1),1);
    for jj = 1:numROI
        included{ii} = included{ii} & inpolygon(posData{ii}(:,views(jj,1)),...
            posData{ii}(:,views(jj,2)),roiVal{jj}(:,1),roiVal{jj}(:,2));
    end
end

end
