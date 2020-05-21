function [] = unitRemover(app, n)
app.s = rmfield(app.s, "waves_"+n);
app.s = rmfield(app.s, "unit_"+n);
app.s.clusters = app.s.clusters(~strcmp(n,app.s.clusters));

app.t.orphanBool(app.t.spikeClust == str2double(n)) = true;
app.t.spikeClust(app.t.spikeClust == str2double(n)) = 0;

if isfield(app.t, 'importedTemplateMapping')
    newMapping = strcmp(n, app.t.importedTemplateMapping{2}(:,1));
    if any(newMapping)
        app.t.importedTemplateMapping{2}(newMapping,:) = [];
    end
end

c = ismember(app.t.refineSettings{1},n);
app.t.refineSettings{1}(c) = [];
app.t.refineSettings{2}(c) = [];
app.s.tags.("unit_"+n) = [];
end