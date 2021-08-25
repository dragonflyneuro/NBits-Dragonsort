function mainLine = plotMainData(app,h,ch)
mainLine = plotBig(h, app.msConvert*(1:size(app.xi,2)), app.xi(ch,:),'Color','b');

xlim(h, [0 app.msConvert*size(app.xi,2)]);
ylim(h, 'auto');
yl = ylim(h);
if ~isinf(app.yLimLowField.Value)
    yl(1) = app.yLimLowField.Value;
end
if ~isinf(app.yLimHighField.Value)
    yl(2) = app.yLimHighField.Value;
end
ylim(h, yl);

end