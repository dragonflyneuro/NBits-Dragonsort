function [titleH, roiH] = makeROISlider(parent,labelT,titleT,width,ticks,initial,func)
set(parent,'Color','none','YColor','none','YTick',[], ...
    'TickDir','both','XMinorTick','on');
disableDefaultInteractivity(parent);
parent.Toolbar.Visible = 'off';
xlabel(parent,labelT,'fontweight','bold');
titleH = title(parent,titleT);
xlim(parent,width);
xticks(parent,ticks);
roiH = images.roi.Line(parent,'Position',[initial(1),0; initial(2),0]);
addlistener(roiH,'MovingROI',@(varargin)roiMoving(roiH,func));
end

function roiMoving(src,func)
src.Position(1,1) = round(src.Position(1,1),2);
src.Position(2,1) = round(src.Position(2,1),2);
src.Position(1,2) = 0;
src.Position(2,2) = 0;
func(sort([src.Position(1,1), src.Position(2,1)]));
end