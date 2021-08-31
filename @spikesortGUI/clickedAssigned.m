function clickedAssigned(app,src,evt,h)
% continue only if selected spike is of the left unit
if ~strcmp(app.LeftUnitDropDown.Value, string(src.UserData))
    return;
end
if app.interactingFlag(1) ~= 0
    return;
end

u = evt.IntersectionPoint;
X = get(src,'XData');
Y = get(src,'YData');
r=sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2);
[~ ,selectedPoint]=min(r);

% continue only if selected spike is plotted in left unit
[~, foundIdx] = ismember(h.UserData{2}(selectedPoint),app.plottedWavesIdx);
if foundIdx < 1
    return;
end

if strcmp(app.pL(foundIdx).LineStyle, ':')
    app.pL(foundIdx).LineStyle = '-';
    temp = get(h, 'UserData');
    h.UserData{1} = temp{1}(temp{1} ~= app.plottedWavesIdx(foundIdx));
else
    app.pL(foundIdx).LineStyle = ':';
    temp = get(h, 'UserData');
    h.UserData{1} = [temp{1} app.plottedWavesIdx(foundIdx)];
end

end