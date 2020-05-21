function [] = unitSplitter(app, n, I)
tU = app.s.("unit_"+n);
tW = app.s.("waves_"+n);

app.StatusLabel.Value = "Splitting unit...";
drawnow
app.incDropDown();
app.s.clusters(end+1) = app.getMaxUnit(0);

%      new unit
moveBool = ismember(app.t.rawSpikeSample, tU(I));
app.t.spikeClust(moveBool) = str2double(app.getMaxUnit(0));
app.unitReassigner(app.getMaxUnit(0), tU(I), tW(I,:,:));

%      old unit
tU(I) = [];
tW(I,:,:) = [];
app.unitReassigner(n, tU, tW);

if isfield(app.t, 'importedTemplateMapping')
    newMapping = strcmp(n, app.t.importedTemplateMapping{2}(:,1));
    if any(newMapping)
        app.t.importedTemplateMapping{2}(end+1,:) = [app.getMaxUnit(0) app.t.importedTemplateMapping{2}(newMapping,2)];
    end
end

c = ismember(app.t.refineSettings{1},n);
app.t.refineSettings{1}(end+1) = app.getMaxUnit(0);
app.t.refineSettings{2}(c) = 1;
app.t.refineSettings{2}(end+1) = 1;

app.s.tags("Junk",:).("unit_"+n) = 0;
app.s.tags.("unit_"+app.getMaxUnit(0)) = false(size(app.s.tags,1),1);
end