function sliderMoving(~, evt, h)
for ii = 1:length(h.Children)
    h.Children(ii).SizeData = evt.Value;
end
end