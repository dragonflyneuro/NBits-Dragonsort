f = uifigure;
ax = axes(f);
q = rand(4,3);
l = plot3(ax,q(:,1),q(:,2),q(:,3),'Marker','o','LineStyle','none');
set(l, 'ButtonDownFcn',{@clickedAssigned,ax});
% set(ax, 'ButtonDownFcn',{@boxClick,ax});
hold on

%%
function clickedAssigned(src,evt,ax)
% continue only if selected spike is of the left unit
u = evt.IntersectionPoint;
X = get(src,'XData');
Y = get(src,'YData');
Z = get(src,'ZData');
r = sqrt((u(1,1)-X).^2+(u(1,2)-Y).^2+(u(1,3)-Z).^2);
[~ ,selectedPoint]=min(r);

scatter3(ax,X(selectedPoint),Y(selectedPoint),Z(selectedPoint),'ro');
end