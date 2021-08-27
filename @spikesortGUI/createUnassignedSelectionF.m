function [] = createUnassignedSelectionF(app)
hF = app.dataFeatureAx;
UD = app.dataAx.UserData.selectedUnassigned;
app.pSelectedF = [];

X = get(app.pUnassignedF,'XData');
Y = get(app.pUnassignedF,'YData');
Z = get(app.pUnassignedF,'ZData');

if ~isempty(Z)
    for ii = UD
        app.pSelectedF(end+1) = scatter3(hF, X(ii),Y(ii),Z(ii),'ro');
    end
else
    for ii = UD
        app.pSelectedF(end+1) = scatter(hF, X(ii),Y(ii),'ro');
    end
end
hF.Children = hF.Children([length(UD)+1:end, 1:length(UD)]);

hF.Children = hF.Children([length(UD)+1:end,...
    1:length(UD)]);

end