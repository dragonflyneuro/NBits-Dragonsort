function sliderMoving(~, evt, h)
for ii = 1:length(h.Children)
    h.Children(ii).MarkerSize = evt.Value;
end
end