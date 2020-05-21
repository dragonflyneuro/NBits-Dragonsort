function [] = unitSorter(app)
for ii = app.s.clusters
    [app.s.("unit_"+ii), IA, ~] = unique(app.s.("unit_"+ii));
    app.s.("waves_"+ii) = app.s.("waves_"+ii)(IA,:,:);
end
end