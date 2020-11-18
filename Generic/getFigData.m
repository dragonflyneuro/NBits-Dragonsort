function [pressedEnter, figData] = getFigData(f)
% Daniel Ko (dsk13@ic.ac.uk), [Feb 2020]
% Returns figure embedded data if enter is pressed, otherwise returns
% empty. Closes figure if enter was pressed
% 
% INPUT
% f = figure handle
% 
% OUTPUT
% pressedEnter = 1 if enter pressed, 0 otherwise
% figData = figure embedded data

figOpen = 1;
while figOpen
	try
		w = waitforbuttonpress;
	catch
		figOpen = 0;
		figData = [];
		pressedEnter = 0;
	end
	if ~ishandle(f)
		figOpen = 0;
		figData = [];
		pressedEnter = 0;
	elseif w
		k = get(f, 'CurrentCharacter');
		if k == 13
			figOpen = 0;
			figData = get(f,'UserData');
			close(f);
			pressedEnter = 1;
        elseif k == 27
            figOpen = 0;
            figData = [];
            close(f);
            pressedEnter = 0;
        end
	end
end
end