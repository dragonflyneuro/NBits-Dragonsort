function sliderMoving(~, e, h)
for ii = 1:length(h.Children)
    h.Children(ii).SizeData = e.Value;
end
end