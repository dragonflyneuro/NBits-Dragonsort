function I = interactiveDataPicker(f, ax, markers)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Takes figure and axes handles to a figure with markers (created by
% plot/line commands) then allows the user to select/deselect individual
% markers by clicking/boxing. Indices of selected markers along the dataset
% are returned. Also adds numerical hotkeys for easy zooming/panning.
% 
% INPUT
% f = figure containing ax
% ax = axes containing markers to interact with
% markers = line object of marker points
% 
% OUTPUT
% I = indices of selected markers along the dataset of markers

I = [];
count = 1;
exitBool = 0;
while 1
	try
		if exitBool
			I = []; break;
		end
		
		[x,y,b] = ginput(1);
		if isempty(b)
			close(f);
			break;
		elseif b == 1
			X=get(markers,'XData'); Y=get(markers,'YData');
			XScale=diff(get(ax,'XLim')); YScale=diff(get(ax,'YLim'));
			r=sqrt(((X -x)./XScale).^2+((Y-y)./YScale).^2);
			[mr,selectedPoint]=min(r);
			if mr < 0.012
				alreadySelectedBool = I == selectedPoint;
				if ~nnz(alreadySelectedBool)
					I = [I, selectedPoint];
					p(count) = plot(ax, X(selectedPoint),Y(selectedPoint),'ro');
					count = count+1;
				else
					delete(p(alreadySelectedBool))
					p(alreadySelectedBool) = []; I(alreadySelectedBool) = [];
					count = count-1;
				end
				
			else
				box(1) = plot(ax, x, y, 'b+', 'MarkerSize', 20);
				[x2,y2,~] = ginput(1);
				box(2) = plot(ax, x2, y2, 'b+', 'MarkerSize', 20);
				xBox = [x, x2, x2, x, x];
				yBox = [y, y, y2, y2, y];
				box(3) = plot(ax, xBox, yBox, 'b');
				selectedPoint = inpolygon(X,Y,xBox,yBox);
				selectedPoint = find(selectedPoint);
				drawnow
				
				for ii = 1:length(selectedPoint)
					alreadySelectedBool = I == selectedPoint(ii);
					if ~any(alreadySelectedBool)
						I = [I, selectedPoint(ii)];
						p(count) = plot(ax, X(selectedPoint(ii)),Y(selectedPoint(ii)),'ro');
						count = count+1;
					else
						delete(p(alreadySelectedBool))
						p(alreadySelectedBool) = []; I(alreadySelectedBool) = [];
						count = count-1;
					end
				end
				delete(box);
				
			end
		else
			exitBool = waiter(f, ax);
		end
	catch
		I = []; break;
	end
end

end

function e = waiter(f, ax)

e = 0;
while b == 49 || b == 50 || b == 51 || b == 52
	w = 0;
	switch b
		case 49 %1 on numpad
			zoom(ax,'on');
		case 50 %2 on numpad
			zoom(ax,'out');
		case 51 %3 on numpad
			pan(ax,'on');
		case 52 %4 on numpad
			pan(ax,'off');
			zoom(ax,'off');
			break;
	end
	while ~w
		w = waitforbuttonpress;
	end
	b = get(f, 'CurrentCharacter');
	if ~ishandle(f)
		e = 1;
		break;
	end
end

end