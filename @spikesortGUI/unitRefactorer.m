function [] = unitRefactorer(app)
if length(app.s.clusters) <= 1
    return;
end

for ii = app.s.clusters
    if isempty(app.s.("unit_"+ii))
        app.unitRemover(ii);
    end
end

tempS.clusters = string.empty();
tempS.tags = table('RowNames', app.s.tags.Row);

tempT = app.t;
if isfield(app.t, 'importedTemplateMapping')
    tempT.importedTemplateMapping{1} = app.t.importedTemplateMapping{1};
    tempT.importedTemplateMapping{2} = string.empty(0,2);
    for ii = tempT.importedTemplateMapping{1}(:,2)'
        tempT.("template_"+ii) = app.t.("template_"+ii);
    end
end

% find order of peak amplitude
c = 1;
minMean = zeros(1,length(app.s.clusters));
for ii = app.s.clusters
    waveAmp = min(mean(app.s.("waves_"+ii)(:,:,app.m.mainCh),1));
    if ~isempty(waveAmp)
        minMean(c) = waveAmp;
    end
    c = c+1;
end
[~, clustMaxOrder] = sort(minMean);

c = 1;
for ii = app.s.clusters(clustMaxOrder)
    if isfield(app.t, 'importedTemplateMapping')
        newMapping = strcmp(ii, app.t.importedTemplateMapping{2}(:,1));
        if any(newMapping)
            tempT.importedTemplateMapping{2}(end+1,:) = [string(c) app.t.importedTemplateMapping{2}(newMapping,2)];
        end
    end
    
    if isfield(app.s, "unit_"+ii)
        tempS.("unit_"+c) = app.s.("unit_"+ii);
        tempS.("waves_"+c) = app.s.("waves_"+ii);
        tempS.clusters(c) = string(c);
        tempT.spikeClust(app.t.spikeClust == str2double(ii)) = c;
        
        tempS.tags.("unit_"+c) = app.s.tags.("unit_"+ii);
        
        tempT.refineSettings{1}(c) = string(c);
        tempT.refineSettings{2}(c) = app.t.refineSettings{2}(ismember(app.t.refineSettings{1}, ii));
        
        if strcmpi(ii, app.LeftUnitDropDown.Value)
            newL = c;
        end
        if strcmpi(ii, app.RightUnitDropDown.Value)
            newR = c;
        end
        c = c + 1;
    end
end

tempT.orphanBool = ~logical(tempT.spikeClust);
app.s = tempS;
app.t = tempT;
app.LeftUnitDropDown.Items = app.s.clusters;
app.RightUnitDropDown.Items = app.s.clusters;

if ~exist('newL','var')
    newL = 1;
end
if ~exist('newR','var')
    newR = 1;
end

app.LeftUnitDropDown.Value = string(newL);
app.RightUnitDropDown.Value = string(newR);

end