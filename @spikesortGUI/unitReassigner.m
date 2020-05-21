function [] = unitReassigner(app, n, u, w)
app.s.("unit_"+n) = u;
app.s.("waves_"+n) = w;
end